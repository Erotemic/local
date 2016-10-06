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
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#ifdef _WIN32
#else
#include <time.h>
#include <sys/time.h>
#endif

// for usleep
#include <unistd.h>


/*#ifndef PROGITER_H_INCLUDED*/
/*#define PROGITER_H_INCLUDED*/
/*#include <stdlib.h>*/

typedef struct {
    int nTotal;
    char* lbl;

    // Timing info
    double flush_freq_sec;

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

    void (*begin)();
    void (*end)();
    /*void (*marki)(void* self, int i);*/
    /*void (*markf)(int i, const char* fmt, ...);*/
} ProgIter;

void ProgIter_marki(ProgIter *self, int i);
void ProgIter_markf(ProgIter *self, int i, const char * format, ...);
void ProgIter_init(ProgIter *self, int nTotal_, char* lbl_);
void ProgIter_begin(ProgIter *self);
void ProgIter_end(ProgIter *self);
void ProgIter_delete(ProgIter *self);

/*#endif*/
/// ------


//  Windows
#ifdef _WIN32
#else
//  Posix/Linux
double ProgIter_now_wall()
{
    struct timeval time;
    if (gettimeofday(&time, NULL))
    {
        //  Handle error
        return 0;
    }
    return (double) time.tv_sec + (double) time.tv_usec * .000001;
}
#endif

void ProgIter_update_measures_wall(ProgIter* self, int i)
{
    self->current_time = ProgIter_now_wall(self);
    self->sec_since_last = (self->current_time - self->prev_flush_time);
    self->total_sec = (self->current_time - self->start_time );
    self->iter_per_sec = (double) (i) / self->total_sec;
    self->est_sec_remain = (double) (self->nTotal - i) / self->iter_per_sec;
}

void ProgIter_flush_if_requested(ProgIter* self)
{
    if (self->sec_since_last > self->flush_freq_sec)
    {
        fflush(stdout);
        self->prev_flush_time = ProgIter_now_wall(self);
    }
}

void ProgIter_clear_buffer(ProgIter* self)
{
    if (self->nbytes_have > 0)
    {
        free(self->extra_buffer);
        self->nbytes_have = 0;
    }
}

void ProgIter_ensure_buffer(ProgIter* self, size_t nbytes_need){
    if (nbytes_need > self->nbytes_have)
    {
        if (self->nbytes_have > 0)
        {
            free(self->extra_buffer);
        }
        self->nbytes_have = nbytes_need;
        self->extra_buffer = (char*) malloc(self->nbytes_have);
    }
}


void ProgIter_delete(ProgIter *self)
{
    ProgIter_clear_buffer(self);
}

void ProgIter_begin(ProgIter *self)
{
    self->start_time = ProgIter_now_wall(self);
    self->prev_flush_time = self->start_time;
    fprintf(stdout,"\33[2K\r%s begin...", self->lbl);
    fflush(stdout);
}

void ProgIter_marki(ProgIter *self, int i)
{
    // function to mark standard progress
    ProgIter_update_measures_wall(self, i);
    fprintf(stdout,"%c[2K", 27);
    /*fprintf(stdout,"\33[2K");*/
    fprintf(stdout,"\r%s %d/%d rate=%.2fHz, etr=%ds, total=%.2fs",
            self->lbl, i, self->nTotal, self->iter_per_sec,
            (int) self->est_sec_remain, self->total_sec);
    ProgIter_flush_if_requested(self);
}

void ProgIter_markf(ProgIter *self, int i, const char * format, ...){
    // function to mark customized progress using printf-like syntax
    // @param i: current iteration number
    // @param extra: customized message
    va_list args;
    va_start(args, format);
    // Check to make sure we have a big enough extra_buffer
    size_t nbytes_need = vsnprintf(NULL, 0, format, args) + 1;
    ProgIter_ensure_buffer(self, nbytes_need);
    vsnprintf(self->extra_buffer, self->nbytes_have, format, args);
    va_end(args);
    ProgIter_update_measures_wall(self, i);
    fprintf(stdout,"%c[2K", 27);
    //const char* CLEARLINE_EL2 = "\33[2K";
    fprintf(stdout,"\r%s %d/%d rate=%.2fHz, etr=%ds, total=%.2fs %s",
            self->lbl, i, self->nTotal, self->iter_per_sec,
            (int) self->est_sec_remain, self->total_sec, self->extra_buffer);
    ProgIter_flush_if_requested(self);
}

void ProgIter_end(ProgIter *self)
{
    ProgIter_marki(self, self->nTotal);
    fprintf(stdout,"\n");
    fflush(stdout);
}


void ProgIter_init(ProgIter *self, int nTotal_, char* lbl_)
{
    self->nTotal = nTotal_;
    self->lbl = lbl_;
    self->flush_freq_sec = 1.0;
    self->nbytes_have = 0;
    self->begin = ProgIter_begin;
    self->end = ProgIter_end;
    /*self->marki = ProgIter_marki;*/
    /*self->markf = ProgIter_markf;*/
}



int main(int argc, char** argv)
{
    /*

    astyle --style=ansi --indent=spaces  --indent-classes  --indent-switches \
    --indent-col1-comments --pad-oper --unpad-paren --delete-empty-lines \
    --add-brackets *.c

    gcc progiter.c && ./a.out
    gcc -D _BSD_SOURCE -std=c99 progiter.c && ./a.out
     */
    int N = 1000;
    char* lbl = "[TestProgIter C]";
    ProgIter prog;
    ProgIter_init(&prog, N, lbl);
    prog.begin();
    /*ProgIter_begin(&prog);*/

    size_t extra_buffsize = 10000;
    char* buf = (char*) malloc(extra_buffsize);
    setbuffer(stdout, buf, extra_buffsize);

    double microseconds = .1 * 1000000;
    int i;
    for (i=0; i < N; i++)
    {
        ProgIter_marki(&prog, i);
        /*ProgIter_markf(&prog, i, "label");*/
        usleep((unsigned int) microseconds);
        //fprintf(stdout,"\n");
        //fprintf(stdout,"microseconds=%d\n", microseconds);

        /*fprintf(stdout,"current_time=%.2f\n", prog.current_time);*/
        /*fprintf(stdout,"start_time=%.2f\n", prog.start_time);*/
        /*fprintf(stdout,"prev_flush_time=%.2f\n", prog.prev_flush_time);*/

        /*fprintf(stdout,"total_sec=%.2f\n", prog.total_sec);*/
        /*fprintf(stdout,"sec_since_last=%.2f\n", prog.sec_since_last);*/
        /*fprintf(stdout,"iter_per_sec=%.2f\n", prog.iter_per_sec);*/
        /*fprintf(stdout,"est_sec_remain=%.2f\n", prog.est_sec_remain);*/
        /*fprintf(stdout,"nbytes_have=%ld\n", prog.nbytes_have);*/
    }
    prog.end();
    ProgIter_delete(&prog);
    /*ProgIter_end(&prog);*/
    return 0;
}
