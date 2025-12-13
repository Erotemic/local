"""
On local (because filezilla doesn't resolve symlinks)

/home/joncrall/Pictures/Remote

rsync -avpLP "steamdeck:Pictures/Steam Screenshots/" "$HOME/Pictures/Remote"

"""

import glob
import os
import pathlib
import re


def _tokenize_vdf(text: str):
    """
    Tokenize Steam KeyValues / VDF into a stream of:
      - '{' or '}'
      - quoted strings
    """
    tokens = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c.isspace():
            i += 1
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            # line comment
            j = text.find("\n", i)
            if j == -1:
                break
            i = j + 1
            continue
        if c in "{}":
            tokens.append(c)
            i += 1
            continue
        if c == '"':
            i += 1
            out = []
            while i < n:
                c = text[i]
                if c == "\\" and i + 1 < n:
                    # keep escaped char (Steam uses \" and \\ sometimes)
                    out.append(text[i + 1])
                    i += 2
                    continue
                if c == '"':
                    i += 1
                    break
                out.append(c)
                i += 1
            tokens.append("".join(out))
            continue

        # Unquoted junk: skip until whitespace/braces (rare in Steam files)
        i += 1

    return tokens


def _parse_vdf_tokens(tokens):
    """
    Parse tokens produced by _tokenize_vdf into nested dicts.
    This is a minimal KeyValues parser.
    """

    def parse_object(idx):
        obj = {}
        key = None
        while idx < len(tokens):
            tok = tokens[idx]
            if tok == "}":
                return obj, idx + 1
            if tok == "{":
                # A brace without a key is unusual; treat as anonymous object skip
                child, idx = parse_object(idx + 1)
                if key is not None:
                    obj[key] = child
                    key = None
                continue

            # tok is a string
            if key is None:
                key = tok
                idx += 1
            else:
                # value can be string or object
                if idx + 1 < len(tokens) and tokens[idx + 1] == "{":
                    child, idx2 = parse_object(idx + 2)
                    obj[key] = child
                    key = None
                    idx = idx2
                else:
                    obj[key] = tok
                    key = None
                    idx += 1

        return obj, idx

    # Many VDF files are top-level: key { ... }
    idx = 0
    top = {}
    while idx < len(tokens):
        tok = tokens[idx]
        if tok in ("{", "}"):
            idx += 1
            continue
        key = tok
        idx += 1
        if idx < len(tokens) and tokens[idx] == "{":
            child, idx = parse_object(idx + 1)
            top[key] = child
        elif idx < len(tokens):
            top[key] = tokens[idx]
            idx += 1
    return top


def load_vdf(path: pathlib.Path) -> dict:
    text = path.read_text(encoding="utf-8", errors="replace")
    tokens = _tokenize_vdf(text)
    return _parse_vdf_tokens(tokens)


def discover_steam_roots() -> list[pathlib.Path]:
    """
    Return plausible Steam installation roots on Ubuntu.
    """
    home = pathlib.Path.home()
    candidates = [
        home / ".steam/debian-installation",  # typical modern ubuntu install
        home / ".local/share/Steam",  # another common layout
        home / ".steam/steam",  # sometimes a symlink
    ]
    roots = [p for p in candidates if p.exists()]
    # de-dupe (resolve if possible)
    seen = set()
    out = []
    for p in roots:
        try:
            rp = p.resolve()
        except Exception:
            rp = p
        if rp not in seen:
            seen.add(rp)
            out.append(p)
    return out


def discover_libraryfolders_vdf(steam_root: pathlib.Path) -> list[pathlib.Path]:
    """
    Find the canonical libraryfolders.vdf files for a steam root.
    Intentionally ignores compatdata/proton copies.
    """
    vdfs = []
    for rel in ["steamapps/libraryfolders.vdf", "config/libraryfolders.vdf"]:
        p = steam_root / rel
        if p.exists():
            vdfs.append(p)
    return vdfs


def extract_library_paths_from_libraryfolders(vdf_obj: dict) -> list[pathlib.Path]:
    """
    Supports both old and new libraryfolders.vdf formats.
    """
    root = vdf_obj.get("libraryfolders", vdf_obj)
    libs = set()

    if isinstance(root, dict):
        for k, entry in root.items():
            if isinstance(entry, dict):
                p = entry.get("path")
                if p:
                    libs.add(pathlib.Path(p))
            elif isinstance(entry, str) and k.isdigit():
                # old format: "0" "/path/to/library"
                libs.add(pathlib.Path(entry))

    return sorted(libs)


def discover_all_library_steamapps_dirs() -> tuple[
    list[pathlib.Path], list[pathlib.Path]
]:
    """
    Returns: (steam_roots, steamapps_dirs)
    """
    steam_roots = discover_steam_roots()
    steamapps_dirs = set()

    for root in steam_roots:
        # the root itself is effectively a "library"
        steamapps_dirs.add(root / "steamapps")

        for vdf_path in discover_libraryfolders_vdf(root):
            try:
                vdf_obj = load_vdf(vdf_path)
            except Exception as e:
                print(f"Warning: failed to parse {vdf_path}: {e}")
                continue

            libs = extract_library_paths_from_libraryfolders(vdf_obj)
            for lib in libs:
                steamapps_dirs.add(lib / "steamapps")

    # keep only existing steamapps dirs
    steamapps_dirs = sorted(p for p in steamapps_dirs if p.exists())
    return steam_roots, steamapps_dirs


def discover_userdata_dirs(steam_roots: list[pathlib.Path]) -> list[pathlib.Path]:
    """
    Find userdata dirs across steam roots.
    """
    out = []
    for root in steam_roots:
        p = root / "userdata"
        if p.exists():
            out.append(p)
    return out


def parse_acf_file_builtin(manifest_path):
    """
    Manually parses a Steam appmanifest .acf file to find the AppID and Name.
    Uses regex to extract keys and values.
    """
    app_id = None
    game_name = None

    # Regex to find lines with a quoted key and a quoted value
    # e.g., "appid"		"12345"
    pattern = re.compile(r'"(\w+)"\s+"(.*)"')

    try:
        with open(manifest_path, "r", encoding="utf-8") as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    key = match.group(1)
                    value = match.group(2)
                    if key == "appid":
                        app_id = value
                    elif key == "name":
                        game_name = value

                # Stop if both required values are found
                if app_id and game_name:
                    break
    except Exception as e:
        print(f"Error reading or parsing manifest file {manifest_path}: {e}")

    return app_id, game_name


def get_game_names_from_local_files_builtin(steam_apps_path):
    """Parses appmanifest_*.acf files using builtin functions to create a dictionary of AppID: GameName."""
    name_map = {}
    manifest_files = glob.glob(str(steam_apps_path / "appmanifest_*.acf"))

    for manifest_path in manifest_files:
        app_id, game_name = parse_acf_file_builtin(manifest_path)
        if app_id and game_name:
            name_map[app_id] = game_name

    return name_map


def create_screenshot_symlinks():
    # Define target directory (~/Pictures/Steam Screenshots)
    pictures_dir = pathlib.Path.home() / "Pictures" / "Steam Screenshots"

    # Create target directory if it doesn't exist
    if not pictures_dir.exists():
        pictures_dir.mkdir(parents=True)
        print(f"Created directory: {pictures_dir}")

    # # Locate the Steam userdata directory on the Steam Deck (Linux path)
    # home_dir = pathlib.Path.home()
    # steam_userdata_path = home_dir / ".local/share/Steam/userdata"
    # steam_apps_path = home_dir / ".local/share/Steam/steamapps"

    # if not steam_userdata_path.exists():
    #     raise Exception(
    #         f"Error: Steam userdata path not found at {steam_userdata_path}"
    #     )

    steam_roots, steamapps_dirs = discover_all_library_steamapps_dirs()
    userdata_dirs = discover_userdata_dirs(steam_roots)

    if not userdata_dirs:
        raise Exception("Error: could not find any Steam userdata directories in discovered Steam roots.")

    # Get the dictionary mapping AppIDs to game names
    game_names = {}
    for steam_apps_path in steamapps_dirs:
        game_names |= get_game_names_from_local_files_builtin(steam_apps_path)

    # Find screenshot folders across all userdata dirs
    screenshot_folders = []
    for ud in userdata_dirs:
        screenshot_folders.extend(glob.glob(str(pathlib.Path(ud) / '*/760/remote/*/screenshots')))
    # de-dupe
    screenshot_folders = sorted(set(screenshot_folders))

    # Find all screenshot folders recursively
    # The structure is .../userdata/<steam_id>/760/remote/<app_id>/screenshots/
    # screenshot_folders = glob.glob(
    #     str(steam_userdata_path / "*/760/remote/*/screenshots")
    # )

    if not screenshot_folders:
        raise Exception("No screenshot folders found.")

    print(f"Found {len(screenshot_folders)} screenshot folders.")

    for folder_path in screenshot_folders:
        src_folder = pathlib.Path(folder_path)

        # Extract the App ID from the path (e.g., the number between 'remote/' and '/screenshots')
        match = re.search(r"/remote/(\d+)/screenshots", str(src_folder))
        if match:
            app_id = match.group(1)
            # You might want to use a service like SteamDB to get the actual game name
            # For this script, we will just use the App ID for the folder name
            game_name = f"Game_{app_id}"

            # Use the retrieved game name, or fallback to the App ID if name not found
            game_name = game_names.get(app_id, f"Unknown_Game_{app_id}")
            print(game_name)

            # Sanitize the game name for use as a folder name (remove invalid characters)
            safe_game_name = re.sub(r'[<>:"/\\|?*]', "_", game_name)

            dest_link_path = pictures_dir / safe_game_name

            # Create the symbolic link
            if not dest_link_path.exists() and not dest_link_path.is_symlink():
                try:
                    # Use relative path for link target for better portability if the Pictures folder is moved to an SD card
                    # This might require some path manipulation
                    # For simplicity, using absolute paths for src, relative path for link
                    os.symlink(src_folder, dest_link_path, target_is_directory=True)
                    print(f"Created symlink for {game_name} -> {src_folder}")
                except FileExistsError:
                    print(f"Link already exists: {dest_link_path}")
                except OSError as e:
                    print(f"Failed to create symlink for {game_name}: {e}")
            else:
                print(f"Link or folder already exists for {game_name}. Skipping.")
        else:
            print(f"Could not determine App ID for folder: {src_folder}")

    print("\nScript finished.")
    print(f"You can find your screenshot links in: {pictures_dir}")


if __name__ == "__main__":
    create_screenshot_symlinks()
