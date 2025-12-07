#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Configuration
###############################################################################

# Where to clone the source repo
SRC_PARENT="$HOME/code"

# Git repo + local directory name
REPO_URL="https://github.com/jellyfin/jellyfin-media-player.git"
REPO_NAME="jellyfin-media-player"
REPO_DIR="$SRC_PARENT/$REPO_NAME"

# Where to install the built application
INSTALL_PREFIX="$HOME/.local/opt/jellyfin-media-player"

# Path to the installed binary
JF_BIN="$INSTALL_PREFIX/bin/jellyfinmediaplayer"

# Icon source (inside the repo) and destination
ICON_SRC_PNG="$REPO_DIR/resources/images/icon.png"
ICON_DEST_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

# Desktop entry settings
JF_DESKTOP_ID="jellyfin-media-player"
JF_APP_NAME="Jellyfin Media Player"
DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/${JF_DESKTOP_ID}.desktop"

# APT packages needed (Ubuntu/Debian-based)
APT_PACKAGES=(
  autoconf automake build-essential cmake curl g++ git
  libasound2-dev libcec-dev libegl1-mesa-dev libfontconfig1-dev
  libfribidi-dev libgl1-mesa-dev libgnutls28-dev
  libharfbuzz-dev libpulse-dev libsdl2-dev libtool libuchardet-dev
  libva-dev libvdpau-dev libx11-dev libxrandr-dev mesa-common-dev
  meson python3
  qml6-module-qtqml-workerscript
  qml6-module-qtquick-controls
  qml6-module-qtquick-templates
  qml6-module-qtquick-window
  qml6-module-qtwebchannel
  qml6-module-qtwebengine
  qml6-module-qtwebengine-controlsdelegates
  qml6-module-qtwebview
  qt6-base-private-dev qt6-webengine-private-dev
  unzip wget yasm zlib1g-dev
  libmpv-dev
)

apt_ensure(){
    __doc__="
    Checks to see if the packages are installed and installs them if needed.

    The main reason to use this over normal apt install is that it avoids sudo
    if we already have all requested packages.

    Args:
        *ARGS : one or more requested packages

    Example:
        apt_ensure git curl htop
    "
    # Note the $@ is not actually an array, but we can convert it to one
    # https://linuxize.com/post/bash-functions/#passing-arguments-to-bash-functions
    ARGS=("$@")
    MISS_PKGS=()
    HIT_PKGS=()
    _SUDO=""
    if [ "$(whoami)" != "root" ]; then
        # Only use the sudo command if we need it (i.e. we are not root)
        _SUDO="sudo "
    fi
    for PKG_NAME in "${ARGS[@]}"
    do
        # Check if the package is already installed or not
        if dpkg-query -W -f='${Status}' "$PKG_NAME" 2>/dev/null | grep -q "install ok installed"; then
            echo "Already have PKG_NAME='$PKG_NAME'"
            HIT_PKGS+=("$PKG_NAME")
        else
            echo "Do not have PKG_NAME='$PKG_NAME'"
            MISS_PKGS+=("$PKG_NAME")
        fi
    done

    # Install the packages if any are missing
    if [ "${#MISS_PKGS[@]}" -gt 0 ]; then
        DEBIAN_FRONTEND=noninteractive $_SUDO apt install -y "${MISS_PKGS[@]}"
    else
        echo "No missing packages"
    fi
}


###############################################################################
# Functions
###############################################################################

install_apt_packages() {
  echo "==> Installing APT build dependencies (idempotent)..."
  apt_ensure "${APT_PACKAGES[@]}"
}

clone_or_update_repo() {
  echo "==> Preparing source directory at: $REPO_DIR"
  mkdir -p "$SRC_PARENT"

  if [[ -d "$REPO_DIR/.git" ]]; then
    echo "    Repo exists, updating..."
    git -C "$REPO_DIR" fetch --all --prune
    git -C "$REPO_DIR" pull --ff-only
  else
    echo "    Cloning repo..."
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  echo "==> Syncing submodules..."
  git -C "$REPO_DIR" submodule sync --recursive
  git -C "$REPO_DIR" submodule update --init --recursive
}

build_and_install_jmp() {
  echo "==> Configuring, building, and installing Jellyfin Media Player..."

  local build_dir="$REPO_DIR/build"
  mkdir -p "$build_dir"

  cmake \
    -S "$REPO_DIR" \
    -B "$build_dir" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -G Ninja

  ninja -C "$build_dir"
  ninja -C "$build_dir" install

  echo "    Installed to: $INSTALL_PREFIX"
}

install_icon_and_desktop() {
  echo "==> Installing icon and .desktop launcher"

  # Sanity check for binary
  if [[ ! -x "$JF_BIN" ]]; then
    echo "ERROR: Expected binary not found or not executable:"
    echo "  $JF_BIN"
    echo "Build/install step may have failed."
    exit 1
  fi

  # Icon
  if [[ -f "$ICON_SRC_PNG" ]]; then
    echo "    Installing icon from: $ICON_SRC_PNG"
    mkdir -p "$ICON_DEST_DIR"
    cp "$ICON_SRC_PNG" "$ICON_DEST_DIR/${JF_DESKTOP_ID}.png"
    echo "    Icon installed to: $ICON_DEST_DIR/${JF_DESKTOP_ID}.png"
  else
    echo "WARNING: Icon not found at:"
    echo "  $ICON_SRC_PNG"
    echo "         Launcher will use a generic icon."
  fi

  # .desktop file
  echo "    Creating desktop file at: $DESKTOP_FILE"
  mkdir -p "$DESKTOP_DIR"

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=${JF_APP_NAME}
Comment=Jellyfin Desktop Application
Exec=${JF_BIN}
Icon=${JF_DESKTOP_ID}
Terminal=false
Type=Application
Categories=AudioVideo;Video;Player;
StartupNotify=true
EOF

  # Validate .desktop file if possible
  if command -v desktop-file-validate >/dev/null 2>&1; then
    echo "    Validating .desktop file..."
    if desktop-file-validate "$DESKTOP_FILE"; then
      echo "    .desktop file is valid."
    else
      echo "WARNING: desktop-file-validate reported issues with $DESKTOP_FILE"
    fi
  else
    echo "    desktop-file-validate not found; skipping validation."
  fi

  # Update desktop database if possible
  if command -v update-desktop-database >/dev/null 2>&1; then
    echo "    Updating desktop database..."
    update-desktop-database "$DESKTOP_DIR" || true
  else
    echo "    update-desktop-database not found; GNOME will pick it up later."
  fi

  echo "==> Desktop launcher installed."
  echo "    You should now see '${JF_APP_NAME}' in the GNOME application menu."
}

###############################################################################
# Main
###############################################################################

install_apt_packages
clone_or_update_repo
build_and_install_jmp
install_icon_and_desktop

echo "==> All done."
