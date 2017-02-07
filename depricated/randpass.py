#!/usr/bin/python
# -*- coding: utf-8 -*-

import random, itertools, os, sys

def main(argv):
    try:
        nwords = int(argv[1])
    except IndexError:
        return usage(argv[0])

    try:
        nbits = int(argv[2])
    except IndexError:
        nbits = 11

    #filename = os.path.join(os.environ['HOME'], 'devel', 'wordlist')
    #filename = os.path.join(os.environ['HOME'], 'devel', 'wordlist')
    filename = '/usr/share/dict/british-english'
    wordlist = read_file(filename, nbits)
    if len(wordlist) != 2**nbits:
        sys.stderr.write("%r contains only %d words, not %d.\n" %
                         (filename, len(wordlist), 2**nbits))
        return 2

    display_password(generate_password(nwords, wordlist), nwords, nbits)
    return 0

def usage(argv0):
    p = sys.stderr.write
    p("Usage: %s nwords [nbits]\n" % argv0)
    p("Generates a password of nwords words, each with nbits bits\n")
    p("of entropy, choosing words from the first entries in\n")
    p("$HOME/devel/wordlist, which should be in the same format as\n")
    p("<http://canonical.org/~kragen/sw/wordlist>, which is a text file\n")
    p("with one word per line, preceded by its frequency, most frequent\n")
    p("words first.\n")
    p("\nRecommended:\n")
    p("    %s 5 12\n" % argv0)
    p("    %s 6\n" % argv0)
    return 1

def read_file(filename, nbits):
    return [line.split()[1] for line in
            itertools.islice(open(filename), 2**nbits)]

def generate_password(nwords, wordlist):
    choice = random.SystemRandom().choice
    return ' '.join(choice(wordlist) for ii in range(nwords))

def display_password(password, nwords, nbits):
    print 'Your password is "%s".' % password
    entropy = nwords * nbits
    print "That's equivalent to a %d-bit key." % entropy
    print

    # My Celeron E1200
    # (<http://ark.intel.com/products/34440/Intel-Celeron-Processor-E1200-(512K-Cache-1_60-GHz-800-MHz-FSB)>)
    # was released on January 20, 2008.  Running it in 32-bit mode,
    # john --test (<http://www.openwall.com/john/>) reports that it
    # can do 7303000 MD5 operations per second, but I’m pretty sure
    # that’s a single-core number (I don’t think John is
    # multithreaded) on a dual-core processor.
    t = years(entropy, 7303000 * 2)
    print "That password would take %.2g CPU-years to crack" % t
    print "on my inexpensive Celeron E1200 from 2008,"
    print "assuming an offline attack on a MS-Cache hash,"
    print "which is the worst password hashing algorithm in common use,"
    print "slightly worse than even simple MD5."
    print

    t = years(entropy, 3539 * 2)
    print "The most common password-hashing algorithm these days is FreeBSD’s"
    print "iterated MD5; cracking such a hash would take %.2g CPU-years." % t
    print

    # (As it happens, my own machines use Drepper’s SHA-2-based
    # hashing algorithm that was developed to replace the one
    # mentioned above; I am assuming that it’s at least as slow as the
    # MD5-crypt.)

    # <https://en.bitcoin.it/wiki/Mining_hardware_comparison> says a
    # Core 2 Duo U7600 can do 1.1 Mhash/s (of Bitcoin) at a 1.2GHz
    # clock with one thread.  The Celeron in my machine that I
    # benchmarked is basically a Core 2 Duo with a smaller cache, so
    # I’m going to assume that it could probably do about 1.5Mhash/s.
    # All common password-hashing algorithms (the ones mentioned
    # above, the others implemented in John, and bcrypt, but not
    # scrypt) use very little memory and, I believe, should scale on
    # GPUs comparably to the SHA-256 used in Bitcoin.

    # The same mining-hardware comparison says a Radeon 5870 card can
    # do 393.46 Mhash/s for US$350.

    print "But a modern GPU can crack about 250 times as fast,"
    print "so that same iterated MD5 would fall in %.1g GPU-years." % (t / 250)
    print

    # Suppose we depreciate the video card by Moore’s law,
    # i.e. halving in value every 18 months.  That's a loss of about
    # 0.13% in value every day; at US$350, that’s about 44¢ per day,
    # or US$160 per GPU-year.  If someone wanted your password as
    # quickly as possible, they could distribute the cracking job
    # across a network of millions of these cards.  The cards
    # additionally use about 200 watts of power, which at 16¢/kWh
    # works out to 77¢ per day.  If we assume an additional 20%
    # overhead, that’s US$1.45/day or US$529/GPU-year.
    cost_per_day = 1.45
    cost_per_crack = cost_per_day * 365 * t
    print "That GPU costs about US$%.2f per day to run in 2011," % cost_per_day
    print "so cracking the password would cost about US$%.1g." % cost_per_crack

def years(entropy, crypts_per_second):
    return float(2**entropy) / crypts_per_second / 86400 / 365.2422

if __name__ == '__main__':
    sys.exit(main(sys.argv))
