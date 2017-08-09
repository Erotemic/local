# -*- coding: utf-8 -*-
#!/usr/bin/env python

import os
from os.path import dirname  # NOQA
import sys

def disable_packages():
    if pkgname == 'OpenBLAS':
        """

        PKGNAME=OpenBLAS
        PKGNAME=Zlib

        find build/src/ -iname CMakeCache.txt -delete
        rm -rf build/src/$PKGNAME*
        rm -rf build/tmp/$PKGNAME*

        rm -rf ${CMAKE_BUILD_DIR}/build/src/${PKGNAME}*
        rm -rf ${CMAKE_BUILD_DIR}/build/tmp/${PKGNAME}*

        REMOVE CMAKE VARS ${PKGNAME}_*
        """
        cmake_build_dir =
        pass
    pass


def kwiver():
    import utool as ut
    ut.codeblock(
        r'''
        # STARTBLOCK bash

        git checkout master

        cd ~/code/kwiver
        rm -rf ~/code/kwiver/build-py2-nocuda
        mkdir -p build-py2-nocuda

        cd ~/code/kwiver/build-py2-nocuda
        cmake -G "Unix Makefiles" \
            -D KWIVER_ENABLE_ARROWS:BOOL=True \
            -D KWIVER_ENABLE_C_BINDINGS:BOOL=True \
            -D KWIVER_ENABLE_PYTHON:BOOL=True \
            -D KWIVER_ENABLE_TESTS:BOOL=True \
            -D PYTHON_VERSION=$(python -c "import sys; print(sys.version[0:3])") \
            -D fletch_DIR:PATH=~/code/fletch/build-py2-nocuda/ \
            ~/code/kwiver

        ''')


def rebase_python3_support():
    import utool as ut
    ut.codeblock(
        r'''
        # STARTBLOCK bash
        cd ~/code/fletch
        git checkout master
        # blow away old branch
        git branch -D tmp/pre-python3-support
        # Recreate the branch
        git checkout -b tmp/pre-python3-support
        # Merge all prereqs into this branch
        git merge dev/find_numpy dev/update-openblas-0.2.20 dev/update-opencv dev/update-vtk dev/update-caffe --no-edit
        # or could do it one at a time, but w/e
        # git merge dev/find_numpy
        # git merge dev/update-openblas-0.2.20 --no-edit
        # git merge dev/update-opencv --no-edit
        # git merge dev/update-vtk --no-edit


        git checkout dev/python3-support

        # Find the oldest merge branch after master
        # This should be the old tmp/pre-python3-support
        OLD_MERGE_POINT=$(python -c "import sys; print(sys.argv[-1])" $(git rev-list --min-parents=2 HEAD ^master))
        # Check to make sure its the merge point
        git log -n 1 $OLD_MERGE_POINT
        echo "$OLD_MERGE_POINT"

        # Find the most recent merge
        # echo $(python -c "import sys; print(sys.argv[-1])" $(git rev-list --min-parents=1 HEAD ^master))

        git checkout tmp/pre-python3-support
        git checkout -b tmp/rebased-python3-support

        # These should be the relevant python3 commits
        git log $OLD_MERGE_POINT..dev/python3-support

        # Move all the relevant python3-support commits onto the new pre-python3-support
        git cherry-pick $OLD_MERGE_POINT..dev/python3-support

        git rebase --onto tmp/rebased-python3-support $OLD_MERGE_POINT

        git checkout dev/python3-support
        git reset --hard tmp/rebased-python3-support

        git push --force

        git checkout tmp/pre-python3-support
        git push --force

        cd ~/code/fletch-expt
        git checkout master
        git branch -D dev/python3-support
        git branch -D tmp/pre-python3-support

        git checkout dev/python3-support

        # git checkout dev/python3-support
        # git checkout -b backup-py3-support

        # git checkout dev/python3-support

        # git merge --strategy-option=theirs tmp/pre-python3-support
        # git rebase -i --strategy-option=theirs tmp/pre-python3-support


        # ENDBLOCK bash
        ''')
    pass


def cuda_fletch():
    """
    # Find cuda version
    nvcc --version
    8.0

    # Find cudnn version
    cat /usr/include/cudnn.h | grep CUDNN_Major -A 2
    6.0

    ldconfig -p | grep libcuda
    ldconfig -p | grep libcudnn


    """


def generate_and_make(repo_dpath, **kwargs):
    import utool as ut

    cmake_vars = {
        # build with
        'fletch_BUILD_WITH_PYTHON': True,
        'fletch_BUILD_WITH_MATLAB': False,
        'fletch_BUILD_WITH_CUDA': False,
        'fletch_BUILD_WITH_CUDNN': False,
        # select version
        'OpenCV_SELECT_VERSION': '3.1.0',
        'VTK_SELECT_VERSION': '6.2.0',
        'fletch_PYTHON_VERSION': sys.version[0:3],
        'PYTHON_EXECUTABLE': sys.executable,
    }
    ut.update_existing(cmake_vars, kwargs)

    DISABLED_LIBS = [  # NOQA
        'ITK',
    ]

    VTK_LIBS = [
        'VTK',
        'TinyXML',
        'libxml2',
        'Qt',
    ]

    ENABLED_LIBS = [
        'Boost', 'Caffe', 'Ceres', 'Eigen', 'FFmpeg', 'GeographicLib',
        'GFlags', 'GLog', 'HDF5', 'jom', 'LevelDB', 'libjpeg-turbo', 'libjson',
        'libkml', 'libtiff',  'LMDB', 'log4cplus', 'OpenBLAS', 'OpenCV',
        'OpenCV_contrib', 'PNG', 'PROJ4', 'Protobuf', 'shapelib', 'Snappy',
        'SuiteSparse', 'VXL', 'yasm', 'ZLib',
    ] + VTK_LIBS

    lines = ['cmake -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=RELEASE']
    lines += ['-D fletch_ENABLE_{}=True'.format(lib) for lib in ENABLED_LIBS]
    lines += ['-D {}={}'.format(key, val) for key, val in cmake_vars.items()]
    lines += [repo_dpath]

    command = ' '.join(lines)
    print(command)

    if False:
        # import utool as ut
        # cmake_retcode = ut.cmd2(command, verbose=True)['ret']
        cmake_retcode = os.system(command)

        if cmake_retcode == 0:
            os.system('make -j9')


if __name__ == '__main__':
    r"""
    CommandLine:
        python ~/local/build_scripts/custom_fletch.py
    """
    # repo_dpath = '~/code/fletch'
    # repo_dpath = dirname(__file__)
    repo_dpath = os.getcwd()

    if repo_dpath.endswith('fletch-expt'):
        kwargs = dict(
            OpenCV_SELECT_VERSION='3.2.0',
            VTK_SELECT_VERSION='8.0',
        )
        generate_and_make(repo_dpath, **kwargs)

    elif repo_dpath.endswith('fletch'):

        generate_and_make(repo_dpath)
