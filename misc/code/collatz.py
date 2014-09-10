import itertools, sys

lambda n: sys.write( itertools.takewhile(lambda n: n != 1, itertools.imap(lambda n_ptr: n_ptr[0] = n_ptr[0]/2.0 if n_ptr[0]%2 == 0 else 3*n_ptr[0]+1, [n])))

collatz = lambda n_ptr: 
    
n_ptr[0] = n_ptr[0]/2.0 if n_ptr[0]%2 == 0 else 3*n_ptr[0]+1

lambda n: map(lambda n_ptr: n_ptr[0]/2.0 if n_ptr[0]%2 == 0 else 3*n_ptr[0]+1, [])
              
              while(collatz([n]) != 1)

def docollatz(n):
    yield n
    Xraise StopIteration

sys.
