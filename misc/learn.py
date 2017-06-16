"""
Script that lets me play with things I'm learning
"""


def pandas_merge():
    import pandas as pd
    x = pd.DataFrame.from_dict(
        {'a': [41, 1], 'b': [2, 1], 'e': [4, 1]}, orient='index')
    y = pd.DataFrame.from_dict(
        {'a': [1, 0], 'b': [2, 0], 'c': [3, 0], 'd': [4, 0]}, orient='index')
    x = x.rename(columns={0: 'foo', 1: 'bar'})
    y = y.rename(columns={0: 'foo', 1: 'bar'})
    new = pd.merge(x, y, how='outer', on=x.columns.tolist(),
                   left_index=True, right_index=True)
    print('new_xy = %r' % (new,))
    new = pd.merge(y, x, how='outer', on=x.columns.tolist(),
                   left_index=True, right_index=True)
    print('new_yx = %r' % (new,))

    a = pd.DataFrame.from_dict(
        {'a': [41, 1], 'b': [2, 1], 'e': [4, 1]}, orient='index')
    b = pd.DataFrame.from_dict(
        {'x': [1, 0], 'y': [2, 0], 'z': [3, 0], 'q': [4, 0]}, orient='index')
    a = a.rename(columns={0: 'foo', 1: 'bar'})

    b = b.rename(columns={0: 'foo', 1: 'bar'})
    new = pd.merge(a, b, how='outer', on=x.columns.tolist(),
                   left_index=True, right_index=True)
    print('new_ab = %r' % (new,))
    new = pd.merge(a, b, how='outer', on=x.columns.tolist(),
                   left_index=True, right_index=True)
    print('new_ba = %r' % (new,))

    import ubelt
    for timer in ubelt.Timerit(10):
        with timer:
            new = pd.merge(a, b, how='outer', on=x.columns.tolist(),
                           left_index=True, right_index=True)
    import ubelt
    for timer in ubelt.Timerit(10):
        with timer:
            new = pd.merge(a, b, how='outer', on=x.columns.tolist(),
                           left_index=True, right_index=True, copy=False)


def iters_until_threshold():
    """
    How many iterations of ewma until you hit the poisson / biniomal threshold

    This establishes a principled way to choose the threshold for the refresh
    criterion in my thesis. There are paramters --- moving parts --- that we
    need to work with: `a` the patience, `s` the span, and `mu` our ewma.

    `s` is a span paramter indicating how far we look back.

    `mu` is the average number of label-changing reviews in roughly the last
    `s` manual decisions.

    These numbers are used to estimate the probability that any of the next `a`
    manual decisions will be label-chanigng. When that probability falls below
    a threshold we terminate. The goal is to choose `a`, `s`, and the threshold
    `t`, such that the probability will fall below the threshold after a maximum
    of `a` consecutive non-label-chaning reviews. IE we want to tie the patience
    paramter (how far we look ahead) to how far we actually are willing to go.
    """
    import numpy as np
    import utool as ut
    import sympy as sym
    i = sym.symbols('i', integer=True, nonnegative=True, finite=True)
    # mu_i = sym.symbols('mu_i', integer=True, nonnegative=True, finite=True)
    s = sym.symbols('s', integer=True, nonnegative=True, finite=True)  # NOQA
    thresh = sym.symbols('thresh', real=True, nonnegative=True, finite=True)  # NOQA
    alpha = sym.symbols('alpha', real=True, nonnegative=True, finite=True)  # NOQA
    c_alpha = sym.symbols('c_alpha', real=True, nonnegative=True, finite=True)
    # patience
    a = sym.symbols('a', real=True, nonnegative=True, finite=True)

    available_subs = {
        a: 20,
        s: a,
        alpha: 2 / (s + 1),
        c_alpha: (1 - alpha),
    }

    def dosubs(expr, d=available_subs):
        """ recursive expression substitution """
        expr1 = expr.subs(d)
        if expr == expr1:
            return expr1
        else:
            return dosubs(expr1, d=d)

    # mu is either the support for the poisson distribution
    # or is is the p in the binomial distribution
    # It is updated at timestep i based on ewma, assuming each incoming responce is 0
    mu_0 = 1.0
    mu_i = c_alpha ** i

    # Estimate probability that any event will happen in the next `a` reviews
    # at time `i`.
    poisson_i = 1 - sym.exp(-mu_i * a)
    binom_i = 1 - (1 - mu_i) ** a

    # Expand probabilities to be a function of i, s, and a
    part = ut.delete_dict_keys(available_subs.copy(), [a, s])
    mu_i = dosubs(mu_i, d=part)
    poisson_i = dosubs(poisson_i, d=part)
    binom_i = dosubs(binom_i, d=part)

    if True:
        # ewma of mu at time i if review is always not label-changing (meaningful)
        mu_1 = c_alpha * mu_0  # NOQA
        mu_2 = c_alpha * mu_1  # NOQA

    if True:
        i_vals = np.arange(0, 100)
        mu_vals = np.array([dosubs(mu_i).subs({i: i_}).evalf() for i_ in i_vals])  # NOQA
        binom_vals = np.array([dosubs(binom_i).subs({i: i_}).evalf() for i_ in i_vals])  # NOQA
        poisson_vals = np.array([dosubs(poisson_i).subs({i: i_}).evalf() for i_ in i_vals])  # NOQA

        # Find how many iters it actually takes my expt to terminate
        thesis_draft_thresh = np.exp(-2)
        np.where(mu_vals < thesis_draft_thresh)[0]
        np.where(binom_vals < thesis_draft_thresh)[0]
        np.where(poisson_vals < thesis_draft_thresh)[0]

    sym.pprint(sym.simplify(mu_i))
    sym.pprint(sym.simplify(binom_i))
    sym.pprint(sym.simplify(poisson_i))

    # Find the thresholds that force termination after `a` reviews have passed
    # do this by setting i=a
    poisson_thresh = binom_i.subs({i: a})
    binom_thresh = poisson_i.subs({i: a})

    sym.pprint(sym.simplify(poisson_thresh))
    sym.pprint(sym.simplify(binom_thresh))

    sym.pprint(sym.simplify(poisson_thresh.subs({s: a})))

    S, A = np.meshgrid(np.arange(1, 200, 5), np.arange(1, 200, 5))
    import plottool as pt
    poisson_zflat = []
    for sval, aval in zip(S.ravel(), A.ravel()):
        poisson_zval = float(poisson_thresh.subs({a: aval, s: sval}).evalf())
        poisson_zflat.append(poisson_zval)
    poisson_zdata = np.array(poisson_zflat).reshape(A.shape)
    fig = pt.figure(fnum=1, doclf=True)
    pt.plot_surface3d(S, A, poisson_zdata, xlabel='s', ylabel='a',
                      zlabel='poisson', mode='wire', contour=True,
                      title='poisson3d')
    fig.savefig('poisson3d.png', dpi=300)

    binom_zflat = []
    for sval, aval in zip(S.ravel(), A.ravel()):
        binom_zval = float(binom_thresh.subs({a: aval, s: sval}).evalf())
        binom_zflat.append(binom_zval)
    binom_zdata = np.array(binom_zflat).reshape(A.shape)
    fig = pt.figure(fnum=2, doclf=True)
    pt.plot_surface3d(S, A, binom_zdata, xlabel='s', ylabel='a',
                      zlabel='binom', mode='wire', contour=True,
                      title='binom3d')
    fig.savefig('binom3d.png', dpi=300)

    # Find point on the surface that achieves a reasonable threshold

    # Sympy can't solve this
    # sym.solve(sym.Eq(binom_thresh.subs({s: 50}), .05))
    # sym.solve(sym.Eq(poisson_thresh.subs({s: 50}), .05))
    # Find a numerical solution
    def solve_numeric(expr, target, want, fixed, method=None, bounds=None):
        """
        Args:
            expr (Expr): symbolic expression
            target (float): numberic value
            fixed (dict): fixed values of the symbol

        expr = poisson_thresh
        expr.free_symbols
        fixed = {s: 10}

        solve_numeric(poisson_thresh, .05, {s: 30}, method=None)
        solve_numeric(poisson_thresh, .05, {s: 30}, method='Nelder-Mead')
        solve_numeric(poisson_thresh, .05, {s: 30}, method='BFGS')
        """
        import scipy.optimize
        # Find the symbol you want to solve for
        want_symbols = expr.free_symbols - set(fixed.keys())
        # TODO: can probably extend this to multiple params
        assert len(want_symbols) == 1, 'specify all but one var'
        assert want == list(want_symbols)[0]
        fixed_expr = expr.subs(fixed)
        def func(a1):
            expr_value = float(fixed_expr.subs({want: a1}).evalf())
            return (expr_value - target) ** 2
        # if method is None:
        #     method = 'Nelder-Mead'
        #     method = 'Newton-CG'
        #     method = 'BFGS'
        # Use one of the other params the startin gpoing
        a1 = list(fixed.values())[0]
        result = scipy.optimize.minimize(func, x0=a1, method=method, bounds=bounds)
        if not result.success:
            print('\n')
            print(result)
            print('\n')
        return result

    # Numeric measurments of thie line

    thresh_vals = [.001, .01, .05, .1, .135]
    svals = np.arange(1, 100)

    target_poisson_plots = {}
    for target in ut.ProgIter(thresh_vals, bs=False, freq=1):
        poisson_avals = []
        for sval in ut.ProgIter(svals, 'poisson', freq=1):
            expr = poisson_thresh
            fixed = {s: sval}
            want = a
            aval = solve_numeric(expr, target, want, fixed,
                                 method='Nelder-Mead').x[0]
            poisson_avals.append(aval)
        target_poisson_plots[target] = (svals, poisson_avals)

    fig = pt.figure(fnum=3)
    for target, dat in target_poisson_plots.items():
        pt.plt.plot(*dat, label='prob={}'.format(target))
    pt.gca().set_xlabel('s')
    pt.gca().set_ylabel('a')
    pt.legend()
    pt.gca().set_title('poisson')
    fig.savefig('numerical_poisson.png', dpi=300)

    target_binom_plots = {}
    for target in ut.ProgIter(thresh_vals, bs=False, freq=1):
        binom_avals = []
        for sval in ut.ProgIter(svals, 'binom', freq=1):
            aval = solve_numeric(binom_thresh, target, a, {s: sval}, method='Nelder-Mead').x[0]
            binom_avals.append(aval)
        target_binom_plots[target] = (svals, binom_avals)

    fig = pt.figure(fnum=4)
    for target, dat in target_binom_plots.items():
        pt.plt.plot(*dat, label='prob={}'.format(target))
    pt.gca().set_xlabel('s')
    pt.gca().set_ylabel('a')
    pt.legend()
    pt.gca().set_title('binom')
    fig.savefig('numerical_binom.png', dpi=300)

    # ----
    if True:

        fig = pt.figure(fnum=5, doclf=True)
        s_vals = [10, 20, 30, 40, 50]
        for sval in s_vals:
            pp = poisson_thresh.subs({s: sval})
            # pp_da1 = sym.diff(pp, a)
            # pp_da2 = sym.diff(pp_da1, a)
            # pp_da3 = sym.diff(pp_da2, a)

            a_vals = np.arange(2, 200)
            pp_vals = np.array([float(pp.subs({a: aval}).evalf()) for aval in a_vals])  # NOQA
            # pp_da1_vals = np.array([float(pp_da1.subs({a: aval}).evalf()) for aval in a_vals])  # NOQA
            # div_vals = np.array([float(pp.subs({a: aval}).evalf()) * aval for aval in a_vals])  # NOQA
            # pp_da2_vals = np.array([float(pp_da2.subs({a: aval}).evalf()) for aval in a_vals])  # NOQA
            # pp_da3_vals = np.array([float(pp_da3.subs({a: aval}).evalf()) for aval in a_vals])  # NOQA

            nrows = 1

            pt.plot(a_vals, pp_vals, label='s=%r' % (sval,))
        pt.legend()
        pt.gca().set_xlabel('a')
        pt.gca().set_ylabel('poisson prob after a reviews')

            # pt.figure(fnum=5, pnum=(nrows, 1, 2))
            # pt.plot(a_vals, pp_da1_vals, label='1st deriv')
            # pt.legend()

            # pt.figure(fnum=5, pnum=(nrows, 1, 3))
            # # pt.plot(a_vals, pp_da2_vals, label='2nd deriv')
            # pt.plot(a_vals, div_vals, label='div')
            # pt.legend()

            # pt.figure(fnum=5, pnum=(nrows, 1, 4))
            # pt.plot(a_vals, pp_da3_vals, label='3nd deriv')
            # pt.legend()


    #---------------------
    # Plot out a table

    mu_i.subs({s: 75, a: 75}).evalf()
    poisson_thresh.subs({s: 75, a: 75}).evalf()

    sval = 50
    for target, dat in target_poisson_plots.items():
        slope = np.median(np.diff(dat[1]))
        aval = int(np.ceil(sval * slope))
        thresh = float(poisson_thresh.subs({s: sval, a: aval}).evalf())
        print('aval={}, sval={}, thresh={}, target={}'.format(aval, sval, thresh, target))

    for target, dat in target_binom_plots.items():
        slope = np.median(np.diff(dat[1]))
        aval = int(np.ceil(sval * slope))
        pass

    # def find_binom_numerical(**kwargs):
    #     def binom_func(aval, sval):
    #         return float(binom_thresh.subs({s: sval, a: aval}).evalf())
    #     def make_minimizer(target, **kwargs):
    #         binom_partial = ut.partial(binom_func, **kwargs)
    #         def min_binom(*args):
    #             return (target - binom_partial(*args)) ** 2
    #         return min_binom
    #     import scipy.optimize
    #     assert bool('aval' in kwargs) != bool('sval' in kwargs), 'specify only one'
    #     x0 = kwargs.get('aval', kwargs.get('sval'))
    #     func = make_minimizer(**kwargs)
    #     result = scipy.optimize.minimize(func, x0=x0)
    #     if not result.success:
    #         print('\n')
    #         print(result)
    #         print('\n')
    #     return result.x[0]

    # def find_poisson_numerical(**kwargs):
    #     def poisson_func(aval, sval):
    #         return float(poisson_thresh.subs({s: sval, a: aval}).evalf())
    #     def make_minimizer(target, **kwargs):
    #         poisson_partial = ut.partial(poisson_func, **kwargs)
    #         def min_poisson(*args):
    #             return (target - poisson_partial(*args)) ** 2
    #         return min_poisson
    #     import scipy.optimize
    #     assert bool('aval' in kwargs) != bool('sval' in kwargs), 'specify only one'
    #     x0 = kwargs.get('aval', kwargs.get('sval'))
    #     func = make_minimizer(**kwargs)
    #     result = scipy.optimize.minimize(func, x0=x0)
    #     if not result.success:
    #         print('\n')
    #         print(result)
    #         print('\n')
    #     return result.x[0]



def ewma():
    import plottool as pt
    import ubelt as ub
    import numpy as np
    pt.qtensure()

    # Investigate the span parameter
    span = 20
    alpha = 2 / (span + 1)

    # how long does it take for the estimation to hit 0?
    # (ie, it no longer cares about the initial 1?)
    # about 93 iterations to get to 1e-4
    # about 47 iterations to get to 1e-2
    # about 24 iterations to get to 1e-1
    # 20 iterations goes to .135
    data = (
        [1] +
        [0] * 20 + [1] * 40 +
        [0] * 20 + [1] * 50 +
        [0] * 20 + [1] * 60 +
        [0] * 20 + [1] * 165 +
        [0] * 20 +
        [0]
    )
    mave = []

    iter_ = iter(data)
    current = next(iter_)
    mave += [current]
    for x in iter_:
        current = (alpha * x) + (1 - alpha) * current
        mave += [current]

    if False:
        pt.figure(fnum=1, doclf=True)
        pt.plot(data)
        pt.plot(mave)

    np.where(np.array(mave) < 1e-1)

    import sympy as sym

    # span, alpha, n = sym.symbols('span, alpha, n')
    n = sym.symbols('n', integer=True, nonnegative=True, finite=True)
    span = sym.symbols('span', integer=True, nonnegative=True, finite=True)
    thresh = sym.symbols('thresh', real=True, nonnegative=True, finite=True)
    # alpha = 2 / (span + 1)

    a, b, c = sym.symbols('a, b, c', real=True, nonnegative=True, finite=True)
    sym.solve(sym.Eq(b ** a, c), a)

    current = 1
    x = 0
    steps = []
    for _ in range(10):
        current = (alpha * x) + (1 - alpha) * current
        steps.append(current)

    alpha = sym.symbols('alpha', real=True, nonnegative=True, finite=True)
    base = sym.symbols('base', real=True, finite=True)
    alpha = 2 / (span + 1)
    thresh_expr = (1 - alpha) ** n
    thresthresh_exprh_expr = base ** n
    n_expr = sym.ceiling(sym.log(thresh) / sym.log(1 -  2 / (span + 1)))

    sym.pprint(sym.simplify(thresh_expr))
    sym.pprint(sym.simplify(n_expr))
    print(sym.latex(sym.simplify(n_expr)))

    # def calc_n2(span, thresh):
    #     return np.log(thresh) / np.log(1 - 2 / (span + 1))

    def calc_n(span, thresh):
        return np.log(thresh) / np.log((span - 1) / (span + 1))

    def calc_thresh_val(n, span):
        alpha = 2 / (span + 1)
        return (1 - alpha) ** n

    span = np.arange(2, 200)
    n_frac = calc_n(span, thresh=.5)
    n = np.ceil(n_frac)
    calc_thresh_val(n, span)

    pt.figure(fnum=1, doclf=True)
    ydatas = ut.odict([
        ('thresh=%f' % thresh, np.ceil(calc_n(span, thresh=thresh)))
        for thresh in [1e-3, .01, .1, .2, .3, .4, .5]

    ])
    pt.multi_plot(span, ydatas,
                  xlabel='span',
                  ylabel='n iters to acheive thresh',
                  marker='',
                  # num_xticks=len(span),
                  fnum=1)
    pt.gca().set_aspect('equal')


    def both_sides(eqn, func):
        return sym.Eq(func(eqn.lhs), func(eqn.rhs))

    eqn = sym.Eq(thresh_expr, thresh)
    n_expr = sym.solve(eqn, n)[0].subs(base, (1 - alpha)).subs(alpha, (2 / (span + 1)))

    eqn = both_sides(eqn, lambda x: sym.log(x, (1 - alpha)))
    lhs = eqn.lhs

    from sympy.solvers.inequalities import solve_univariate_inequality

    def eval_expr(span_value, n_value):
        return np.array([thresh_expr.subs(span, span_value).subs(n, n_)
                         for n_ in n_value], dtype=np.float)

    eval_expr(20, np.arange(20))

    def linear(x, a, b):
        return a * x + b

    def sigmoidal_4pl(x, a, b, c, d):
        return d + (a - d) / (1 + (x / c) ** b)

    def exponential(x, a, b, c):
        return a + b * np.exp(-c * x)

    import scipy.optimize

    # Determine how to choose span, such that you get to .01 from 1
    # in n timesteps
    thresh_to_span_to_n = []
    thresh_to_n_to_span = []
    for thresh_value in ub.ProgIter([.0001, .001, .01, .1, .2, .3, .4, .5]):
        print('')
        test_vals = sorted([2, 3, 4, 5, 6])
        n_to_span = []
        for n_value in ub.ProgIter(test_vals):
            # In n iterations I want to choose a span that the expression go
            # less than a threshold
            constraint = thresh_expr.subs(n, n_value) < thresh_value
            solution = solve_univariate_inequality(constraint, span)
            try:
                lowbound = np.ceil(float(solution.args[0].lhs))
                highbound = np.floor(float(solution.args[1].rhs))
                assert lowbound <= highbound
                span_value = lowbound
            except AttributeError:
                span_value = np.floor(float(solution.rhs))
            n_to_span.append((n_value, span_value))

        # Given a threshold, find a minimum number of steps
        # that brings you up to that threshold given a span
        test_vals = sorted(set(list(range(2, 1000, 50)) + [2, 3, 4, 5, 6]))
        span_to_n = []
        for span_value in ub.ProgIter(test_vals):
            constraint = thresh_expr.subs(span, span_value) < thresh_value
            solution = solve_univariate_inequality(constraint, n)
            n_value = solution.lhs
            span_to_n.append((span_value, n_value))

        thresh_to_n_to_span.append((thresh_value, n_to_span))
        thresh_to_span_to_n.append((thresh_value, span_to_n))

    thresh_to_params = []
    for thresh_value, span_to_n in thresh_to_span_to_n:
        xdata, ydata = [np.array(_, dtype=np.float) for _ in zip(*span_to_n)]

        p0 = (1 / np.diff((ydata - ydata[0])[1:]).mean(), ydata[0])
        func = linear
        popt, pcov = scipy.optimize.curve_fit(func, xdata, ydata, p0)
        # popt, pcov = scipy.optimize.curve_fit(exponential, xdata, ydata)

        if False:
            yhat = func(xdata, *popt)
            pt.figure(fnum=1, doclf=True)
            pt.plot(xdata, ydata, label='measured')
            pt.plot(xdata, yhat, label='predicteed')
            pt.legend()
        # slope = np.diff(ydata).mean()
        # pt.plot(d)
        thresh_to_params.append((thresh_value, popt))

    # pt.plt.plot(*zip(*thresh_to_slope), 'x-')

    # for thresh_value=.01, we get a rough line with slop ~2.302,
    # for thresh_value=.5, we get a line with slop ~34.66

    # if we want to get to 0 in n timesteps, with a thresh_value of
    # choose span=f(thresh_value) * (n + 2))
    # f is some inverse exponential

    # 0.0001, 460.551314197147
    # 0.001, 345.413485647860,
    # 0.01, 230.275657098573,
    # 0.1, 115.137828549287,
    # 0.2, 80.4778885203347,
    # 0.3, 60.2031233261536,
    # 0.4, 45.8179484913827,
    # 0.5, 34.6599400289520

    # Seems to be 4PL symetrical sigmoid
    # f(x) = -66500.85 + (66515.88 - -66500.85) / (1 + (x/0.8604672)^0.001503716)
    # f(x) = -66500.85 + (66515.88 - -66500.85)/(1 + (x/0.8604672)^0.001503716)

    def f(x):
        return -66500.85 + (66515.88 - -66500.85) / (1 + (x/0.8604672) ** 0.001503716)
        # return (10000 * (-6.65 + (13.3015) / (1 + (x/0.86) ** 0.00150)))

    # f(.5) * (n - 1)

    # f(
    solve_rational_inequalities(thresh_expr < .01, n)


def mean_decrease_impurity():
    '''
    N = num training examples

    t = node
    t.num = number of training samples at t

    t.p = t.num / N  = fraction of training samples at t

    p_L = t.left.num / t.num
    p_R = t.right.num / t.num

    i(t) = impurity / entropy class labels at the node

    ∆i(t) = impurity decrease at the node
    ∆i(t) = i(t) − p_L * i(tL) − p_R * i(tR)
    t.∆i t.delta_i = ∆i(t)

    # importance of feature dimension j in tree m
    # This is the weighted impurity decrease of all nodes using that feature in m
    MDI(j, m) = sum(p(t) * ∆i(s, t) for t in m if t.feature = j)
    MDI(j, m) = sum(t.p * t.∆i for t in m if t.feature = j)

    MDI(feat, tree) = sum(node.p * node.delta_i for node in tree if node.feature = feat)

    '''
    import sympy as sym
    n, nL, nR, N, i, iR, iL = sym.symbols('n, n_L, n_R, N, i, iR, iL')

    p = n / N
    pL = nL / N
    pR = nR / N

    wL = nL / n
    wR = nL / n

    delta_i1 = i - (wL * iL + wR * iR)
    delta_i2 = p * i - (pL * iL + pR * iR)

    print('Real Delta ∆i(t)')
    sym.pprint(sym.simplify(delta_i1))

    print('')
    print('Alt Delta ∆i(t)')
    sym.pprint(delta_i2 * N / n)
    sym.pprint(sym.simplify(delta_i2 * N / n))

    sym.pprint(sym.simplify((p * i - (pL * iL + pR * iR)) / p))


def chunked_search():
    """
    Computational complexity of building one kd-tree and searching vs building
    many and searching.


    --------------------------------
    Normal Running Time:
        Indexing:
            D⋅log(D⋅p)
        Query:
            Q⋅log(D⋅p)
    --------------------------------

    --------------------------------
    Chunked Running Time:
        Indexing:
                 ⎛D⋅p⎞
            D⋅log⎜───⎟
                 ⎝ C ⎠
        Query:
                   ⎛D⋅p⎞
            C⋅Q⋅log⎜───⎟
                   ⎝ C ⎠
    --------------------------------

    Conclusion: chunking provides a tradeoff in running time.
    It can make indexing, faster, but it makes query-time slower.  However, it
    does allow for partial database search, which can speed up response time of
    queries. It can also short-circuit itself once a match has been found.
    """
    import sympy as sym
    import utool as ut
    ceil = sym.ceiling
    ceil = ut.identity
    log = sym.log

    #
    # ====================
    # Define basic symbols
    # ====================

    # Number of database and query annotations
    n_dannots, n_qannots = sym.symbols('D, Q')

    # Average number of descriptors per annotation
    n_vecs_per_annot = sym.symbols('p')

    # Size of the shortlist to rerank
    n_rr = sym.symbols('L')

    # The number of chunks
    C = sym.symbols('C')

    #
    # ===============================================
    # Define helper functions and intermediate values
    # ===============================================
    n_dvecs = n_vecs_per_annot * n_dannots

    # Could compute the maximum average matches something gets
    # but for now just hack it
    fmatch = sym.Function('fmatch')
    n_fmatches = fmatch(n_vecs_per_annot)

    # The complexity of spatial verification is roughly that of SVD
    # SV_fn = lambda N: N ** 3  # NOQA
    SV_fn = sym.Function('SV')
    SV = SV_fn(n_fmatches)

    class KDTree(object):
        # A bit of a simplification
        n_trees = sym.symbols('T')
        params = {n_trees}

        @classmethod
        def build(self, N):
            return N * log(N) * self.n_trees

        @classmethod
        def search(self, N):
            # This is average case
            return log(N) * self.n_trees

    Indexer = KDTree

    def sort(N):
        return N * log(N)

    #
    # ========================
    # Define normal complexity
    # ========================

    # The computational complexity of the normal hotspotter pipeline
    normal = {}
    normal['indexing'] = Indexer.build(n_dvecs)
    normal['search'] = n_vecs_per_annot * Indexer.search(n_dvecs)
    normal['rerank'] = (SV * n_rr)
    normal['query'] = (normal['search'] + normal['rerank']) * n_qannots
    normal['total'] = normal['indexing'] + normal['query']

    n_cannots = ceil(n_dannots / C)
    n_cvecs = n_vecs_per_annot * n_cannots

    # How many annots should be re-ranked in each chunk?
    # _n_rr_chunk = sym.Max(n_rr / C * log(n_rr / C), 1)
    # _n_rr_chunk = n_rr / C
    _n_rr_chunk = n_rr

    _index_chunk = Indexer.build(n_cvecs)
    _search_chunk = n_vecs_per_annot * Indexer.search(n_cvecs)
    chunked = {}
    chunked['indexing'] = C * _index_chunk
    chunked['search'] = C * _search_chunk
    # Cost to rerank in every chunk and then merge chunks into a single list
    chunked['rerank'] = C * (SV * _n_rr_chunk) + sort(C * _n_rr_chunk)
    chunked['query'] = (chunked['search'] + chunked['rerank']) * n_qannots
    chunked['total'] = chunked['indexing'] + chunked['query']

    typed_steps = {
        'normal': normal,
        'chunked': chunked,
    }

    #
    # ===============
    # Inspect results
    # ===============

    # Symbols that will not go to infinity
    const_symbols = {
        n_rr,
        n_vecs_per_annot
    }.union(Indexer.params)

    def measure_num(n_steps, step, type_):
        print('nsteps(%s %s)' % (step, type_,))
        sym.pprint(n_steps)

    def measure_order(n_steps, step, type_):
        print('O(%s %s)' % (step, type_,))
        limiting = [
            (s, sym.oo)
            for s in n_steps.free_symbols - const_symbols
        ]
        step_order = sym.Order(n_steps, *limiting)
        sym.pprint(step_order.args[0])

    measure_dict = {
        'num': measure_num,
        'order': measure_order,
    }

    # Different methods for choosing C
    C_methods = ut.odict([
        ('none', C),
        ('const', 512),
        ('linear', n_dannots / 512),
        ('log', log(n_dannots)),
    ])

    # ---
    # What to measure?
    # ---

    steps  = [
        'indexing',
        'query'
    ]
    types_ = ['normal', 'chunked']
    measures = [
        # 'num',
        'order'
    ]
    C_method_keys = [
        'none'
        # 'const'
    ]

    grid = ut.odict([
        ('step', steps),
        ('measure', measures),
        ('k', C_method_keys),
        ('type_', types_),
    ])

    last = None

    for params in ut.all_dict_combinations(grid):
        type_ = params['type_']
        step = params['step']
        k = params['k']
        # now = k
        now = step
        if last != now:
            print('=========')
            print('\n\n=========')
        last = now
        print('')
        print(ut.repr2(params, stritems=True))
        measure_fn = measure_dict[params['measure']]
        info = typed_steps[type_]
        n_steps = info[step]
        n_steps = n_steps.subs(C, C_methods[k])
        measure_fn(n_steps, step, type_)
