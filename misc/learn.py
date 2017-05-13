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
