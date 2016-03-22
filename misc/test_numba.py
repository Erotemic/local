# -*- coding: utf-8 -*-
from __future__ import print_function, division, absolute_import
import utool as ut
import numpy as np
from numba import double, jit, autojit


#class MyClass(object):

#    def mymethod(self, arg):
#        return arg * 2


#@jit
#def call_method(obj):
#    print(obj.mymethod("hello"))   # object result
#    mydouble = obj.mymethod(10.2)  # native double
#    print(mydouble * 2)            # native multiplication

#call_method(MyClass())


def filter2d(image, filt):
    M, N = image.shape
    Mf, Nf = filt.shape
    Mf2 = Mf // 2
    Nf2 = Nf // 2
    result = np.zeros_like(image)
    for i in range(Mf2, M - Mf2):
        for j in range(Nf2, N - Nf2):
            num = 0.0
            for ii in range(Mf):
                for jj in range(Nf):
                    num += (filt[Mf - 1 - ii, Nf - 1 - jj] *
                            image[i - Mf2 + ii, j - Nf2 + jj])
            result[i, j] = num
    return result

# This kind of quadruply-nested for-loop is going to be quite slow.
# Using Numba we can compile this code to LLVM which then gets
# compiled to machine code:
# Now fastfilter_2d runs at speeds as if you had first translated
# it to C, compiled the code and wrapped it with Python
fastfilter_2d = jit(double[:, :](double[:, :], double[:, :]))(filter2d)
autofilter_2d = autojit(filter2d)

# Use utool to time this
imports = ut.codeblock(
    r'''
    # STARTBLOCK
    import numpy as np
    from numba import double, jit, autojit
    # ENDBLOCK
    ''')

datas = ut.codeblock(
    r'''
    # STARTBLOCK
    fastfilter_2d = jit(double[:, :](double[:, :], double[:, :]))(filter2d)
    autofilter_2d = autojit(filter2d)
    rng = np.random.RandomState(0)
    image = rng.rand(100, 100)
    filt = rng.rand(10, 10)
    # ENDBLOCK
    ''')

setup =  '\n'.join([imports, ut.get_func_sourcecode(filter2d), datas])
print(ut.highlight_code(setup))
stmt_list1 = ut.codeblock(
    r'''
    fastfilter_2d(image, filt)
    filter2d(image, filt)
    autofilter_2d(image, filt)
    ''').split('\n')
ut.util_dev.timeit_compare(stmt_list1, setup, int(1))
