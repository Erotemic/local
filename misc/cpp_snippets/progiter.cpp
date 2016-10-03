#include <ctime>
#include <cstdarg>
#include <string.h>
#include <stdlib.h>
#include <string>

#include <cstdio>
#include <cstdlib>
#include <cstring>

//#include <assert.h>
//#include <ctype.h>
//#include <float.h>
//#include <limits.h>
//#include <math.h>
//#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>

//#include <algorithm>
//#include <cmath>
//#include <cstdlib>
//#include <limits>
//#include <float.h>
//#include <cstring>
//#include <cassert>


class ProgIter 
{
public:
    ProgIter(int nTotal_, const std::string &lbl_)
        : nTotal(nTotal_), lbl(lbl_), flush_freq_sec(2.7182), nbytes_have(0) { }
    
    ~ProgIter(){
        if (nbytes_have > 0)
        {
            free(buffer);
            nbytes_have = 0;
        }
    }

    void begin(){
        //const char * lbl = "[cv.kmeans++] ";
        start_clock = std::clock();
        prev_clock = std::clock();
        printf("\r %s", lbl.c_str());
    }

    void markf(int i, const char * format, ...){
        // Allows for customized information to be sent to the progress iter
        va_list args;
        va_start(args, format);
        // Check to make sure we have a big enough buffer
        size_t nbytes_need = vsnprintf(NULL, 0, format, args) + 1;
        if (nbytes_need > nbytes_have)
        {
            if (nbytes_have > 0)
            {
                free(buffer);
            }
            nbytes_have = nbytes_need;
            buffer = (char*) malloc(nbytes_have);
        }
        // Format the extra info
        vsnprintf(buffer, nbytes_have, format, args);
        mark(i, buffer);
        va_end(args);
    }

    void mark(int i)
    {
        mark(i, "");
    }

    void mark(int i, const char* extra)
    {
        //const char * lbl = "[cv.kmeans++] ";
        sec_since_last = (std::clock() - prev_clock) / (double) CLOCKS_PER_SEC;
        total_sec = (std::clock() - start_clock ) / (double) CLOCKS_PER_SEC;
        iter_per_sec = (double) (i) / total_sec;
        est_sec_remain = (double) (nTotal - i) / iter_per_sec;
        printf("\r %s %d/%d rate=%.2fHz, etr=%ds, total=%ds %s", 
                lbl.c_str(), i, nTotal, iter_per_sec, (int) est_sec_remain, (int) total_sec, extra);
        if (sec_since_last > 2.7182)
        {
            fflush(stdout);
        }
    }

    void end()
    {
        mark(nTotal);
        printf("\n");
        fflush(stdout);
    }

private:
    const int nTotal;
    std::string lbl;
    const double flush_freq_sec;
    std::clock_t start_clock;
    std::clock_t prev_clock;
    double total_sec;
    double sec_since_last;
    double iter_per_sec;
    double est_sec_remain;
    size_t nbytes_have;
    char* buffer;
    //= "[cv2.kmeans++] ";
    //const char* lbl;
};
