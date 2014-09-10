:: alias timecmd=time
gcc -o OpenMPTest1.exe main_testomp2.c
chmod +x OpenMPTest1.exe
call timecmd OpenMPTest1.exe
gcc -o OpenMPTest2.exe main_testomp2.c -fopenmp 
call timecmd OpenMPTest2.exe

:: #-lgomp -lpthreadgce2
:: #gcc -o OpenMPTest2 main_testomp.c -libpthreadgc
:: #gcc -static -static-libgcc -static-libstdc++ -o OpenMPTest2.exe main_testomp2.c -fopenmp 
