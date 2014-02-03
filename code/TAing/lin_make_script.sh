mkdir build
rm CMakeCache.txt
cd build
rm CMakeCache.txt
cmake ..
make 
cp ifs ..
cp ~/test_models/*.txt ..
cd ..


./ifs -input sierpinski_triangle.txt -points 10000 -iters 30 -size 200

./ifs -input fern.txt -points 50000 -iters 30 -size 400

./ifs -input giant_x.txt -points 10000 -size 400 -iters 4

./ifs -input giant_x.txt -size 400 -iters 4 -cubes

