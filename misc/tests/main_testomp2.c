#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    long result = 0;
    long i;

#pragma omp parallel for reduction(+: result)
    for (i = 0; i < 100000000; i++) {
        result++;
    }
    printf("%li\n", result);
    return EXIT_SUCCESS;
}
