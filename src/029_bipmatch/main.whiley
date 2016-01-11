// This implements a simple algorithm for solving the perfect
// matching problem over bipartite graphs.  In essence, the problem is to
// determine whether a matching exists for all vertices in a given
// bipartite graph.  The algorithm is apparently an implementation of
// "Kuhn's algorithm", though I haven't found a reference for that yet.
//
//
// The algorithm is relatively straightforward and it proceeds by a
// left-to-right traversal of the vertices in the first partition.  For
// each vertex, if it encounters a neighbour which is unmatched, then it
// will greedily match it.  Otherwise, it attempts to reconfigure the
// currently matching by finding an "augmenting path".  Roughly speaking,
// that is a path from the vertex in question which ends in an unmatched
// vertex.
//
// Author: David J. Pearce, 2016

constant UNMATCHED is -1

// Every edge in our bipartite graph is from one side to the other.
type edge is { int from, int to }

type Graph is {
    int N1,      // size of first partition
    int N2,      // size of second partition
    edge[] edges // edges in graph
}
// Partitions are valid
where N1 >= 0 && N2 >= 0
// All edges are from a valid vertex
where all { i in 0..|edges| | 0 <= edges[i].from && edges[i].from < N1 }
// All edges are to a valid vertex
where all { i in 0..|edges| | 0 <= edges[i].to && edges[i].to < N2 }

type Matching is {
    Graph graph,
    int[] left, // matches from => to
    int[] right // matches to => from
}
// Every vertex is left either unmatched (-1) or a valid vertex in partition two
where all { i in 0..|left| | left[i] >= UNMATCHED && left[i] < graph.N2 }
// Every vertex in right either unmatched (-1) or a valid vertex in partition one
where all { i in 0..|right| | right[i] >= UNMATCHED && right[i] < graph.N1 }
// Every match is symmetric
where all { i in 0..|left| | left[i] == UNMATCHED || right[left[i]] == i }

// Simple constructor for matching
function Matching(Graph g) -> (Matching m)
ensures m.graph == g
// All left vertices are unmatched
ensures all { i in 0..g.N1 | m.left[i] == UNMATCHED }
// All right vertices are unmatched
ensures all { i in 0..g.N2 | m.right[i] == UNMATCHED }:
    //
    return {
        graph: g,
        left: [UNMATCHED; g.N1],
        right: [UNMATCHED; g.N2]
    }

function findMaximalMatching(Graph g) -> (null|Matching r):
    //
    if g.N1 != g.N2:
        // No perfect matching possible
        return null
    else:
        // N1 == N2
        Matching m = Matching(g)
        //
        int i = 0
        while i < g.N1 where i >= 0
        // Every vertex below i is already matched
        where all { j in 0..i | m.left[j] != UNMATCHED }:
            bool[] visited = [false; g.N1]
            m,visited = find(m,visited,i)
            if m.left[i] == UNMATCHED:
                // no match for this vertex possible
                return null
            i = i + 1
        //
        return m

function find(Matching m, bool[] visited, int from) -> (Matching r_m, bool[] r_visited):
    //
    Graph g = m.graph
    visited[from] = true
    //
    int i = 0
    //
    while i < |g.edges| where i >= 0:
        edge e = g.edges[i]
        if e.from == from:
            int tor = m.right[e.to]
            if tor == UNMATCHED:
                // to is unmatched; hence, greedily match it
                m.left[from] = e.to
                m.right[e.to] = from
                return m,visited
            else if !visited[tor]:
                // to is already matched; hence, try to find augmenting path so it can be unmatched.
                m,visited = find(m,visited,tor)
                // FIXME: something is wrong here because cannot get UNMATCHED
                if m.right[e.to] == UNMATCHED:
                    m.left[from] = e.to
                    m.right[e.to] = from
                    return m,visited
        i = i + 1
    //
    // Failed
    // 
    return m,visited