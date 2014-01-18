# from http://en.literateprograms.org/Pi_with_the_BBP_formula_(Python)

D = 14        # number of digits of working precision
M = 16 ** D
SHIFT = (4 * D)
MASK = M - 1

def S(j, n):
    # Left sum
    s = 0
    k = 0
    while k <= n:
        r = 8*k+j
        s = (s + (pow(16,n-k,r)<<SHIFT)//r) & MASK
        k += 1
    # Right sum
    t = 0
    k = n + 1
    while 1:
        xp = int(16**(n-k) * M)
        newt = t + xp // (8*k+j)
        # Iterate until t no longer changes
        if t == newt:
            break
        else:
            t = newt
        k += 1
    return s + t

def pi_intarith(n):
    n -= 1
    x = (4*S(1, n) - 2*S(4, n) - S(5, n) - S(6, n)) & MASK
    return "%014x" % x



from gmpy import mpq, mpz

def mod1(x):
    return x-mpz(x)

def pi_gen():
    x = 0
    n = 1
    while 1:
        p = mpq((120*n-89)*n+16, (((512*n-1024)*n+712)*n-206)*n+21)
        x = mod1(16*x + p)
        n += 1
        yield int(16*x)


import sys
def allpi():
    for n, p in enumerate(pi_gen()):
        sys.stdout.write("%x" % p)
        if n % 1000 == 0:
            sys.stdout.write("\n\n%i\n\n" % n)


allpi()
