gcc -o OpenMPTest main_testomp.c

chmod +x OpenMPTest.exe

time ./OpenMPTest.exe

gcc -o OpenMPTest2 main_testomp.c -fopenmp -lgomp -lpthreadgce2

time ./OpenMPTest2.exe
