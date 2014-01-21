#dpkg -l | grep opencv

# Removing because I think they are conflicting with my dev opencv 

# These are ordered by dependency
# don't change it if you have to redo it
dkpg -r python-opencv
dkpg -r libopencv-legacy2.3
dkpg -r libopencv-objdetect2.3
dkpg -r libopencv-calib3d2.3
dkpg -r libopencv-features2d2.3
dkpg -r libopencv-flann2.3
dkpg -r libopencv-highgui2.3
dkpg -r libopencv-video2.3
dkpg -r libopencv-ml2.3
dkpg -r libopencv-imgproc2.3
dkpg -r libopencv-core2.3
