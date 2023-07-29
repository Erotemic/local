#!/usr/bin/env python

def all_ascii(data):
    """
    Test if a string contains any non-ASCII characters.

    Args:
        data (str): a string to test

    Returns:
        bool: True if there are non-ASCII characters.

    Example:
        >>> official = 'www.paypal.com'
        >>> imposter = 'www.pаypal.com'
        >>> print(all_ascii(official))
        True
        >>> print(all_ascii(imposter))
        False
    """
    ascii_lo = 0
    ascii_hi = 127
    code_points = (ord(c) for c in data)
    all_ascii = all(ascii_lo <= n <= ascii_hi for n in code_points)
    return all_ascii


def main():
    import argparse
    import sys
    parser = argparse.ArgumentParser(
        description='Test if input data is ascii or not',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument('data', help='string to test')
    ns = parser.parse_args()

    if all_ascii(ns.data):
        print('✔ SAFE: data is all ASCII')
        sys.exit(0)
    else:
        print('✗ UNSAFE: data is NOT all ASCII')
        sys.exit(1)

if __name__ == '__main__':
    """
    CommandLine:

        # Official
        python ~/misc/wip/isascii.py www.paypal.com

        # Imposter
        python ~/misc/wip/isascii.py www.pаypal.com
    """
    main()
