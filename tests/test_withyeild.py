#!/usr/bin/env python
from __future__ import absolute_import, division, print_function


class DummyContext(object):
    def __init__(self):
        print('init')

    def __enter__(self):
        print('__enter__')

    def __exit__(self, type, value, traceback):
        print('__exit__')


def test_gen():
    with DummyContext():
        for x in xrange(10):
            print('>>>Yeilding: %r' % x)
            yield x


def main():
    for x in test_gen():
        print('test: %r' % x)


if __name__ == '__main__':
    main()
