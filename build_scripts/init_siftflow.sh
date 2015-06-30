# References: http://richardt.name/publications/video-deanaglyph/
# http://stackoverflow.com/questions/27418668/nonfree-module-is-missing-in-opencv-3-0

code

python -c "import utool as ut; print(ut.grab_zipped_url('http://richardt.name/publications/video-deanaglyph/VideoDeAnaglyph-sources.zip', download_dir='.'))"
mv VideoDeAnaglyph-sources VideoDeAnaglyph

sed -i s/colorcode.h/ColorCode\.h/ VideoDeAnaglyph-sources/Commons/RenderFlow.cpp

sed -i s/opencv2\/nonfree\/features2d.hpp/opencv2\/xfeatures2d.hpp/ ../VideoDeAnaglyph-sources/TemporalConsistency/FeatureFlow.cpp

sed s/opencv2\/nonfree\/features2d.hpp/opencv2\/xfeatures2d.hpp/ ../TemporalConsistency/FeatureFlow.cpp

# Had to remove the nonsiftflow parts of the c++ code
#export PATH=$PATH:/home/joncrall/code/VideoDeAnaglyph-sources/SiftFlow/

cd VideoDeAnaglyph
mkdir build
cd build
cmake ..
make

ut.grab_test_imgpath('easy1.png')
python -c 'import utool as ut; ut.copy(ut.grab_test_imgpath("easy1.png"), ".")'
python -c 'import utool as ut; ut.copy(ut.grab_test_imgpath("easy2.png"), ".")'
python -c 'import utool as ut; ut.copy(ut.grab_test_imgpath("easy3.png"), ".")'
python -c 'import utool as ut; ut.copy(ut.grab_test_imgpath("hard3.png"), ".")'


python -c "from PIL import Image; print(Image.open(\"easy1.png\").format)" easy1.png
python -c "from PIL import Image; print(Image.open(\"easy2.png\").format)" easy1.png
python -c "from PIL import Image; print(Image.open(\"easy3.png\").format)" easy1.png
python -c "from PIL import Image; print(Image.open(\"hard3.png\").format)" easy1.png


cd $CODE_DIR/VideoDeAnaglyph/build

./bin/SiftFlowExample easy1.png easy2.png
./bin/SiftFlowExample easy2.png easy1.png
./bin/SiftFlowExample easy1.png easy3.png
./bin/SiftFlowExample easy3.png easy1.png
./bin/SiftFlowExample easy2.png easy3.png
./bin/SiftFlowExample easy3.png easy2.png
./bin/SiftFlowExample easy1.png hard3.png
