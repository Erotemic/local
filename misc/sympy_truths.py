import sympy
import vtool as vt
a, n = sympy.symbols('a n', real=True)

expr1 = n ** sympy.log(a)
expr2 = a ** sympy.log(n)

domain = {
    a: (-10, 10),
    n: (-10, 10),
}

vt.check_expr_eq(expr1, expr2)
truth_list, results_list, input_list = vt.symbolic_randcheck(expr1, expr2, domain, n=7)


"""
https://en.wikipedia.org/wiki/List_of_logarithmic_identities

log(y, base=b) == y
(b ** y == x)   <==>   (log(x, base=b) == y)
"""
