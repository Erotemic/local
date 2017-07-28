Abbreviations:
    Let local-conn = local-edge-connectivity
    Let k-conn = k-edge-connected

Definitions:
    Let k-cc = a maximal set of nodes k-conn in G.
        (computed using "a simple algorithm for all k-ccs")
    Let k-sub = a maximal set of nodes in G whose subgraph is k-conn.
        (our goal is to compute these)
    Let 𝛿-in(n) - be the in-degree of a node
    Let 𝛿-out(n) - be the out-degree of a node

Algo1:
    Given a k-cc, we form k-subs as follows:

        Let H be the subgraph of G from the nodes in the k-cc.
        while True:
            for each node with 𝛿-in(n) < k or 𝛿-out(n) < k:
                remove that node from H.
            if no node was removed, then break.

        The subgraphs formed by the connected components in H are now the
        k-subs. Note that some k-subs consist of only a single node.
        We call these trivial k-subs. All other k-subs are non-trivial
        and have k-conn between each pair of nodes in the k-sub.

L1: All pairs of nodes in a k-sub are k-conn.
Proof:
    This is true by definition.

L2: Each k-sub is a subset of some k-cc.
Proof:
    Let B = the nodes in some k-sub
    Let C = the nodes in some k-cc

    Let B and C share the nodes T.
    I.E. B ∩ C = T, where T != ∅.

    Assume  B ⊄ C.
    Then there is a nonempty set of nodes S = B - C.
    I.E. S are nodes in B but not in C.

    In the subgraph B, the nodes in S must have local-conn >= k with all
    nodes in T, otherwise B would not B a k-sub. Thus, in the auxillary
    graph there must be an edge with weight >= k connecting the nodes in S
    and T. Thus the nodes in S are connected to the nodes in C in the
    auxillary graph. Therefore nodes in S are in C. This is a
    contradiction. Therefore we conclude ∀ C, ∃ B, such that B ⊂ C.
Collary:
    Each k-sub is disjoint, otherwise they would be the same k-sub.

L3: Algo1 removes only trivial k-subs.
Proof:
    Base case:
        The first iteration of Algo1 only removes nodes in trivial k-subs.

    Given a subgraph H = G.subgraph(C), the nodes removed from H in the
    first iteration do not have k-conn to any other node in H because
    their degree is too small. Thus these nodes cannot be part of any
    non-trivial k-sub, and are therefore part of trivial k-subs.

    Inductive step:
        Assuming the current iteration of Algo1 removed only trivial
        k-subs, the next iteration will also only remove trivial k-subs.

    Similar reasoning to the base case. The nodes removed in the next
    iteration are not k-conn to any other remaining node.  If the nodes
    were previously k-conn to a remaining node, that was due to a path
    through a trivial k-sub. Because that k-sub is trivial it does not
    belong to the same k-sub a node removed in this iteration.  Thus,
    because all pairs of nodes in a k-sub must be k-connected to each
    other, the nodes removed in this iteration belong only trivial k-subs.

    Therefore, by induction, Algo1 removes only trivial k-subs.

PROBLEM: THIS IS NOT TRUE:

L4: The connected components that remain in H after Algo1 is applied are
    maximal k-edge-connected subgraphs.
Proof:
    Because we did not remove nodes from any non-trivial k-sub,
    all nodes from all k-subs remain.

    Furthermore, because all nodes in H
    were previously k-conn in G, and all nodes remaining in H now have
    𝛿-in(n) >= k and 𝛿-out(n) >= k, all pairs of nodes in each connected
    components of H is k-conn.



    (
    if a node u has degrees >= k, after the Algo1 it must be k-conn to all
    other nodes in its connected component in H.

    Assume there are less than k edges that can be cut to separate u from
    some other node v.
    If this was true, then because these nodes were all locally connected
    in G, there must have been a trivial node removed that completed this
    conectivity.

    If it wasn't then there is a cut of fewer than k edges that can
    disconnect u from some other node v in the CC.

    )


    (
    previous statement may need further proof. Assume a pair of nodes
    (u, v) in a CC of H was not k-conn. Then there must be a cut of k
    edge that disconects u and v.
    )

    It must have been k-conn in the
    original graph otherwise it would not be in H. If the connectivity
    between u an v was due to a
