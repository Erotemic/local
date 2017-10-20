cd ~/code/VIAME/plugins/camtrawl/python
export PYTHONPATH=$(pwd):$PYTHONPATH

install/bin/processopedia

workon_py2

export KWIVER_PLUGIN_PATH=""
export SPROKIT_MODULE_PATH=""
source ~/code/VIAME/build/install/setup_viame.sh
export KWIVER_DEFAULT_LOG_LEVEL=debug
export KWIVER_DEFAULT_LOG_LEVEL=info
export KWIVER_PYTHON_DEFAULT_LOG_LEVEL=debug

# export KWIVER_PYTHON_COLOREDLOGS=1

python ~/code/VIAME/plugins/camtrawl/python/run_camtrawl.py
python run_camtrawl.py

~/code/VIAME/build/install/bin/pipeline_runner -p ~/.cache/sprokit/temp_pipelines/temp_pipeline_file.pipe
~/code/VIAME/build/install/bin/pipeline_runner -p camtrawl.pipe -S pythread_per_process


~/code/VIAME/build/install/bin/pipeline_runner -p ~/code/VIAME/examples/hello_world_pipeline/hello_world_detector.pipe
~/code/VIAME/build/install/bin/pipeline_runner -p ~/code/VIAME/examples/tracking_pipelines/simple_tracker.pipe


Tracking related files:

~/code/VIAME/packages/kwiver/

git diff --name-status master..HEAD | grep ^

git diff --name-status dev/segnet..HEAD | grep ^A
git diff --name-status dev/tracking-framework..HEAD | grep ^A
#git merge-base dev/tracking-framework master
#git diff --name-status dev/tracking-framework..1ea4cd274487928c9617f8c26b03fb43369f6ff9 | grep ^A

pypipe()
{
    COMMAND=$1
    #python -c "import sys; [sys.stdout.write(line.replace('$1', '$2')) for line in sys.stdin.readlines()]"
    python -c "import sys; from os.path import *; [sys.stdout.write($1) for line in sys.stdin.readlines()]"
}

replace()
{
    pypipe "line.replace('$1', '$2')"
    #python -c "import sys; [sys.stdout.write(x.replace('$1', '$2')) for x in sys.stdin.readlines()]"
}

abspath()
{
    pypipe "abspath(line)"
    #python -c "import os, sys; [sys.stdout.write(os.path.abspath(x)) for x in sys.stdin.readlines()]"
}

filter-file-diff()
{
    grep ^$1 | replace "$1\t" "" | abspath | pypipe "'$1 ' + line" 
}


git-new-files(){
    BRANCH=$1
    MASTER=$2
    MERGE_BASE=$(git merge-base $MASTER $BRANCH)
    git diff --name-status $MERGE_BASE..$BRANCH | filter-file-diff A
    #git diff --name-status $MERGE_BASE..$BRANCH | filter-file-diff D
    #python -c "import os, sys; [sys.stdout.write(os.path.abspath(x.replace('A\t', ''))) for x in sys.stdin.readlines()]"
}

BRANCH=dev/tracking-framework 
BASE=master

git-new-files dev/tracking-framework master
git-new-files dev/tracking-framework HEAD


A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/associate_detections_to_tracks_threshold.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/associate_detections_to_tracks_threshold.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/compute_association_matrix_from_features.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/compute_association_matrix_from_features.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/initialize_object_tracks_threshold.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/initialize_object_tracks_threshold.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/read_object_track_set_kw18.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/read_object_track_set_kw18.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/read_track_descriptor_set_csv.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/read_track_descriptor_set_csv.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/write_object_track_set_kw18.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/write_object_track_set_kw18.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/write_track_descriptor_set_csv.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/core/write_track_descriptor_set_csv.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/darknet/generate_headers.py
A /home/joncrall/code/VIAME/packages/kwiver/arrows/ocv/refine_detections_draw.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/ocv/refine_detections_draw.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/ocv/split_image.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/ocv/split_image.h
A /home/joncrall/code/VIAME/packages/kwiver/arrows/vxl/split_image.cxx
A /home/joncrall/code/VIAME/packages/kwiver/arrows/vxl/split_image.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/associate_detections_to_tracks_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/associate_detections_to_tracks_process.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/compute_association_matrix_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/compute_association_matrix_process.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/compute_track_descriptors_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/initialize_object_tracks_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/initialize_object_tracks_process.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/read_object_track_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/read_object_track_process.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/read_track_descriptor_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/read_track_descriptor_process.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/split_image_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/split_image_process.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/write_object_track_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/write_object_track_process.h
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/write_track_descriptor_process.cxx
A /home/joncrall/code/VIAME/packages/kwiver/sprokit/processes/core/write_track_descriptor_process.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/associate_detections_to_tracks.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/associate_detections_to_tracks.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/compute_association_matrix.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/compute_association_matrix.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/initialize_object_tracks.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/initialize_object_tracks.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/read_object_track_set.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/read_object_track_set.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/read_track_descriptor_set.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/read_track_descriptor_set.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/split_image.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/split_image.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/write_object_track_set.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/write_object_track_set.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/write_track_descriptor_set.cxx
A /home/joncrall/code/VIAME/packages/kwiver/vital/algo/write_track_descriptor_set.h
A /home/joncrall/code/VIAME/packages/kwiver/vital/bindings/c/types/track_set.hxx

