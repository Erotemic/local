/*
 * Basic Usage
 N = 10;
 ProgIter prog = ProgIter(N)
 prog.begin();
 for (int i = 0; i < N: i++){
     prog.mark(i);
     // dostuff
 }
 prog.end();
 */
#include <string.h>
#include <stdlib.h>
#include <ctime>
#include <cstdarg>
#include <string>

#include <cstdio>
#include <cstdlib>
#include <cstring>

//#include <chrono>

// For test script
#include <unistd.h>

#ifdef _WIN32
#include <Windows.h>
#else
#include <time.h>
#include <sys/time.h>
#endif


class ProgIter 
{
public:
    ProgIter(int nTotal_, const std::string &lbl_)
        : nTotal(nTotal_), lbl(lbl_), flush_freq_sec(2.7182), nbytes_have(0) { }

    ProgIter(int nTotal_)
        : nTotal(nTotal_), lbl(""), flush_freq_sec(2.7182), nbytes_have(0) { }

    ~ProgIter(){
        clear_buffer();
    }

    void begin(){
        this->start_time = this->now_wall();
        this->prev_flush_time = this->now_wall();
        printf("\33[2K\r%s", this->lbl.c_str());
        fflush(stdout);
    }

    void end()
    {
        mark(this->nTotal);
        printf("\n");
        fflush(stdout);
    }

    void mark(int i)
    {
        // function to mark standard progress
        this->update_measures_wall(i);
        printf("\33[2K\r%s %d/%d rate=%.2fHz, etr=%ds, total=%.2fs", 
                this->lbl.c_str(), i, this->nTotal, this->iter_per_sec, 
                (int) this->est_sec_remain, this->total_sec);
        this->flush_if_requested();
    }

    void mark(int i, const char * format, ...){
        // function to mark customized progress using printf-like syntax
        // @param i: current iteration number
        // @param extra: customized message
        va_list args;
        va_start(args, format);
        // Check to make sure we have a big enough extra_buffer
        size_t nbytes_need = vsnprintf(NULL, 0, format, args) + 1;
        this->ensure_buffer(nbytes_need);
        vsnprintf(this->extra_buffer, this->nbytes_have, format, args);
        va_end(args);
        this->update_measures_wall(i);
        //default_timer = time.time
        //# http://www.uqac.ca/flemieux/PRO100/VT100_Escape_Codes.html
        //# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_codes
        //CLEARLINE_EL0 = '\33[0K'
        //CLEARLINE_EL1 = '\33[1K'
        //CLEARLINE_EL2 = '\33[2K'
        //BEFORE_MSG = '\r' + CLEARLINE_EL2
        //AFTER_MSG = CLEARLINE_EL0
        //AT_END = '\033[?25h\n'
        //const char* CLEARLINE_EL2 = "\33[2K";
        //# Erase in-line escape sequences
        //# ESC = chr(27)
        //# ESC + '[0K']
        //# ESC + '[1K']
        //
        printf("\33[2K\r%s %d/%d rate=%.2fHz, etr=%ds, total=%.2fs %s", 
                this->lbl.c_str(), i, this->nTotal, this->iter_per_sec, 
                (int) this->est_sec_remain, (int) this->total_sec, 
                this->extra_buffer);
        this->flush_if_requested();
    }

protected:
    
    // C++ 11 way
    //double now_wall()
    //{
        //auto now = std::chrono::system_clock::now();
        //auto now_ms = std::chrono::time_point_cast<std::chrono::milliseconds>(now);
        //auto value = now_ms.time_since_epoch();
        //long milliseconds = value.count();
        //double seconds = (double) milliseconds / 1000.0;
        //return seconds;
    //}

    //double now_cpu()
    //{
    //    auto now = std::clock();
    //    double seconds = now / (double) CLOCKS_PER_SEC;
    //    return seconds;
    //}

    //  Windows
    #ifdef _WIN32
    double now_wall()
    {
        LARGE_INTEGER time,freq;
        if (!QueryPerformanceFrequency(&freq))
        {
            return 0;
        }
        if (!QueryPerformanceCounter(&time))
        {
            return 0;
        }
        return (double)time.QuadPart / freq.QuadPart;
    }

    double now_cpu()
    {
        FILETIME a,b,c,d;
        if (GetProcessTimes(GetCurrentProcess(),&a,&b,&c,&d) != 0)
        {
            //  Returns total user time.
            //  Can be tweaked to include kernel times as well.
            return
                (double)(d.dwLowDateTime |
                ((unsigned long long)d.dwHighDateTime << 32)) * 0.0000001;
        }
        else
        {
            return 0;
        }
    }

    //  Posix/Linux
    #else
    double now_wall()
    {
        struct timeval time;
        if (gettimeofday(&time, NULL))
        {
            //  Handle error
            return 0;
        }
        return (double) time.tv_sec + (double) time.tv_usec * .000001;
    }

    double now_cpu()
    {
        return (double) std::clock() / (double) CLOCKS_PER_SEC;
    }
    #endif

    void update_measures_wall(int i)
    {
        this->current_time = this->now_wall();
        this->sec_since_last = (this->current_time - this->prev_flush_time);
        this->total_sec = (this->current_time - this->start_time );
        this->iter_per_sec = (double) (i) / this->total_sec;
        this->est_sec_remain = (double) (this->nTotal - i) / this->iter_per_sec;
    }

    void flush_if_requested()
    {
        if (this->sec_since_last > this->flush_freq_sec)
        {
            fflush(stdout);
            this->prev_flush_time = this->now_wall();
        }
    }

    void clear_buffer()
    {
        if (this->nbytes_have > 0)
        {
            free(this->extra_buffer);
            this->nbytes_have = 0;
        }
    }

    void ensure_buffer(size_t nbytes_need){
        if (nbytes_need > this->nbytes_have)
        {
            if (this->nbytes_have > 0)
            {
                free(this->extra_buffer);
            }
            this->nbytes_have = nbytes_need;
            this->extra_buffer = (char*) malloc(this->nbytes_have);
        }
    }


public:
    const int nTotal;
    std::string lbl;

    // Timing info
    const double flush_freq_sec;

    double start_time;
    double current_time;
    double prev_flush_time;

    double total_sec;
    double sec_since_last;
    double iter_per_sec;
    double est_sec_remain;
    // Custom measures
    size_t nbytes_have;
    char* extra_buffer;
};



int main(int argc, char** argv)
{
    /*
     
    astyle --style=ansi --indent=spaces  --indent-classes  --indent-switches \
    --indent-col1-comments --pad-oper --unpad-paren --delete-empty-lines \
    --add-brackets *.cpp

    clang progiter.cpp  -std=c++11 -lstdc++
    gcc progiter.cpp  -lstdc++ && ./a.out
     */
    int N = 1000;
    ProgIter prog = ProgIter(N, "[TestProgIter C++]");
    prog.begin();
    double microseconds = .1 * 1000000;
    for (int i=0; i < N; i++)
    {
        prog.mark(i);
        usleep((int) microseconds);
        //printf("\n");
        //printf("microseconds=%d\n", microseconds);

        //printf("current_time=%.2f\n", prog.current_time);
        //printf("start_time=%.2f\n", prog.start_time);
        //printf("prev_flush_time=%.2f\n", prog.prev_flush_time);

        //printf("total_sec=%.2f\n", prog.total_sec);
        //printf("sec_since_last=%.2f\n", prog.sec_since_last);
        //printf("iter_per_sec=%.2f\n", prog.iter_per_sec);
        //printf("est_sec_remain=%.2f\n", prog.est_sec_remain);
        //printf("nbytes_have=%ld\n", prog.nbytes_have);
    }
    prog.end();
    return 0;
}
