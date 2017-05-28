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
    thresh_expr = base ** n
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
    calc_val(n, span)

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
