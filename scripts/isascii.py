#!/usr/bin/env python
import sys


def analyze_ascii(data, fix=False):
    """
    Analyze a string for ASCII compliance.

    Args:
        data (str): the input string.

    Returns:
        dict: {
            'is_ascii': bool,
            'non_ascii': List[Tuple[int, str, int]],
            'replacement': str
        }

        - is_ascii: True if all characters are ASCII.
        - non_ascii: list of (index, character, code point) for each non-ASCII character.
        - replacement: ASCII-only string with non-ASCII characters replaced by '?'.
    """
    non_ascii = [(i, c, ord(c)) for i, c in enumerate(data) if ord(c) > 127]
    is_ascii = len(non_ascii) == 0
    # replacement = ''.join(c if ord(c) <= 127 else '?' for c in data)
    if fix:
        replacement = ''.join(c if ord(c) <= 127 else ascii_replace(c) for c in data)
    else:
        replacement = None
    return {
        'is_ascii': is_ascii,
        'non_ascii': non_ascii,
        'replacement': replacement,
    }


# TODO: use a transliteration library (e.g. unidecode)
UTF_REPLACEMENT_MAP = {
    '\u2018': "'",     # LEFT SINGLE QUOTATION MARK
    '\u2019': "'",     # RIGHT SINGLE QUOTATION MARK
    '\u201C': '"',     # LEFT DOUBLE QUOTATION MARK
    '\u201D': '"',     # RIGHT DOUBLE QUOTATION MARK
    '\u2013': '-',     # EN DASH
    '\u2014': '-',     # EM DASH
    '\u2026': '...',   # ELLIPSIS
    '\u00A0': ' ',     # NO-BREAK SPACE
    '\u00AB': '<<',    # «
    '\u00BB': '>>',    # »
    '\u2022': '*',     # BULLET
    "\u0430": 'a',     # cyrillic 'a'
    '\u2010': '-',     # HYPHEN
    '\u2011': '-',     # NON-BREAKING HYPHEN
    '\u2012': '-',     # FIGURE DASH
    '\u2015': '-',     # HORIZONTAL BAR
    '\u2032': "'",     # PRIME (minutes, feet)
    '\u2033': '"',     # DOUBLE PRIME (seconds, inches)
    '\u00B4': "'",     # ACUTE ACCENT
    '\u02C6': '^',     # MODIFIER LETTER CIRCUMFLEX ACCENT
    '\u02DC': '~',     # SMALL TILDE
    '\u00B8': ',',     # CEDILLA
    '\u00E9': 'e',     # é -> e (if you want to strip accents)
    '\u00E0': 'a',     # à -> a
    '\u00F4': 'o',     # ô -> o
    '\u00FC': 'u',     # ü -> u
    '\u00E7': 'c',     # ç -> c
    '\u2122': '(TM)',  # TRADE MARK SIGN
    '\u00AE': '(R)',   # REGISTERED SIGN
    '\u00A9': '(C)',   # COPYRIGHT SIGN
    '\u200B': '',      # ZERO WIDTH SPACE (remove)
    '\uFEFF': '',      # ZERO WIDTH NO-BREAK SPACE (BOM)
    # Add more mappings as needed
}


def ascii_replace(char):
    """
    Replace a non-ASCII character with a reasonable ASCII equivalent, if possible.
    """
    if char in UTF_REPLACEMENT_MAP:
        return UTF_REPLACEMENT_MAP[char]
    import unicodedata
    # Try to decompose accented letters: e.g., é → e
    decomposed = unicodedata.normalize('NFKD', char)
    ascii_equiv = ''.join(c for c in decomposed if ord(c) < 128)
    return ascii_equiv if ascii_equiv else '?'


def read_stdin_if_available():
    if not sys.stdin.isatty():
        return sys.stdin.read().strip()
    return None


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description='Check if a string is ASCII and show non-ASCII details.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument('data', nargs='?', help='String to test')
    parser.add_argument('-f', '--fix', action='store_true',
                        help='Do not print suggested ASCII-only replacement')
    args = parser.parse_args()

    if args.data is None:
        stdin_data = read_stdin_if_available()
        if stdin_data:
            args.data = stdin_data
        else:
            parser.error('No input data provided. Provide as argument or pipe via stdin.')

    result = analyze_ascii(args.data, fix=args.fix)

    if result['is_ascii']:
        print('✔ SAFE: data is all ASCII')
        return 0
    else:
        if args.fix:
            print('✗ UNSAFE: data contains non-ASCII characters:')
            for idx, char, code in result['non_ascii']:
                print(f'  - Position {idx}: {repr(char)} (U+{code:04X}), replacement: {ascii_replace(char)!r}')
            print('')
            print('Suggested replacement:\n')
            print(result["replacement"])
            print('')
        print('✗ UNSAFE: data contains non-ASCII characters. Use --fix to output replacements')
        return 1


if __name__ == '__main__':
    """
    CommandLine:

        # ASCII input
        python isascii.py www.paypal.com

        # Non-ASCII input (Cyrillic 'а')
        python isascii.py www.pаypal.com

        # Suppress replacement suggestion
        python isascii.py www.pаypal.com --no-replace
    """
    sys.exit(main())
