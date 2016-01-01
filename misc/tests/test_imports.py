# flake8: noqa
from __future__ import absolute_import, division, print_function
## Python
from collections import OrderedDict, defaultdict, namedtuple
from os.path import (dirname, realpath, join, exists, normpath, splitext,
                     expanduser, relpath, isabs, commonprefix, basename)
from itertools import chain, cycle
import six
from six.moves import zip, map, zip_longest, builtins, cPickle
from itertools import product as iprod
import argparse
import atexit
import copy
import colorsys
import datetime
import decimal
import fnmatch
import functools
import hashlib
import imp
import inspect
import itertools
import logging
import multiprocessing
import operator
import os
import platform
import re
import shelve
import shlex
import shutil
import signal
import site
import subprocess
import sys
import textwrap
import time
import types
import uuid
import urllib
import warnings
import zipfile
if not sys.platform.startswith('win32'):
    import resource
# PIPI
if six.PY2:
    import functools32
import psutil
# Qt
import sip
#import guitool.__PYQT__ as __PYQT__
#from guitool import __PYQT__
#from guitool.__PYQT__ import QtCore, QtGui
#from guitool.__PYQT__.QtCore import Qt
## Matplotlib
#from plottool import __MPL_INIT__
#import PyQt4
#__MPL_INIT__.init_matplotlib()
##mpl.use('Qt4Agg')  # pyinstaller hack
#import matplotlib
#import matplotlib as mpl
#import matplotlib.pyplot as plt
## Scientific
#import numpy as np
#import numpy.linalg as npl
#from numpy import (array, rollaxis, sqrt, zeros, ones, diag)
#from numpy.core.umath_tests import matrix_multiply
#import cv2
#from PIL import Image
#from PIL.ExifTags import TAGS
#from scipy.cluster.hierarchy import fclusterdata
#from sklearn.cluster import MeanShift, estimate_bandwidth
import pandas as pd
