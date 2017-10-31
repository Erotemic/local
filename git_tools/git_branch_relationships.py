#!/usr/bin/env python
import itertools as it
import ubelt as ub


def check_relationships(branches):

    ancestors = {b: set() for b in branches}
    length = len(branches) * (len(branches) - 1)
    for b1, b2 in ub.ProgIter(it.combinations(branches, 2), length=length):
        ret = ub.cmd('git merge-base --is-ancestor {} {}'.format(b1, b2))['ret']
        if ret == 0:
            ancestors[b1].add(b2)
        ret = ub.cmd('git merge-base --is-ancestor {} {}'.format(b2, b1))['ret']
        if ret == 0:
            ancestors[b2].add(b1)
    print('<key> is an ancestor of <value>')
    print(ub.repr2(ancestors))

    descendants = {b: set() for b in branches}
    for key, others in ancestors.items():
        for o in others:
            descendants[o].add(key)
    print('<key> descends from <value>')
    print(ub.repr2(descendants))

    import plottool as pt
    import networkx as nx
    G = nx.DiGraph()
    G.add_nodes_from(branches)
    for key, others in ancestors.items():
        for o in others:
            # G.add_edge(key, o)
            G.add_edge(o, key)

    from networkx.algorithms.connectivity.edge_augmentation import collapse
    flag = True
    G2 = G
    while flag:
        flag = False
        for u, v in list(G2.edges()):
            if G2.has_edge(v, u):
                G2 = collapse(G2, [[u, v]])

                node_relabel = ub.ddict(list)
                for old, new in G2.graph['mapping'].items():
                    node_relabel[new].append(old)
                G2 = nx.relabel_nodes(G2, {k: '\n'.join(v) for k, v in node_relabel.items()})
                flag = True
                break

    G3 = nx.transitive_reduction(G2)
    pt.show_nx(G3, arrow_width=1.5, prog='dot', layoutkw=dict(prog='dot'))
    pt.zoom_factory()
    pt.pan_factory()
    pt.plt.show()


if __name__ == '__main__':
    r"""
    CommandLine:
        export PYTHONPATH=$PYTHONPATH:/home/joncrall/misc
        python ~/misc/git-branch-relationships.py

        python ~/misc/git-branch-relationships.py "
            jon/viame/master jon/viame/next master dev/tracking-framework
            viame/master viame/query-wip viame/tracking-work
            viame/master-no-pybind viame/master-w-pytorch
            "
    """

    # branches = [x.strip() for x in '''
    #             jon/viame/master
    #             jon/viame/next
    #             master
    #             dev/tracking-framework
    #             viame/master
    #             viame/query-wip
    #             viame/tracking-work
    #             viame/master-no-pybind
    #             viame/master-w-pytorch
    #             '''.splitlines() if x.strip()]

    import sys
    argv = sys.argv[1:]

    branches = []
    for item in argv:
        for sub in item.split():
            sub = sub.strip()
            if sub:
                branches.append(sub)

    print('branches = {}'.format(ub.repr2(branches)))
    check_relationships(branches)
