#!/usr/bin/env python
# -*- coding: utf-8 -*-
from setuptools import setup


def myextra():
    print("EXTRA EXTRA EXTRA")


if __name__ == '__main__':
    setup(
        name='testmod',
        version=1,
        extras_require={
            'myextra': myextra
        },
    )
