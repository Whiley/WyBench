// This implements a simple algorithm for solving the perfect
// matching problem over bipartite graphs.  In essence, the problem is to
// determine whether a matching exists for all vertices in a given
// bipartite graph.  The algorithm is apparently an implementation of
// "Kuhn's algorithm", though I haven't found a reference for that yet.
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
import std::ascii

int UNMATCHED = -1

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
where all { i in 0..|edges| | N1 <= edges[i].to && edges[i].to < (N1+N2) }

type Matching is {
    Graph graph,
    int[] left, // matches from => to
    int[] right // matches to => from
}
// Every vertex is left either unmatched (-1) or a valid vertex in partition two
where all { i in 0..|left| | left[i] >= UNMATCHED && left[i] < (graph.N1+graph.N2) }
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
        right: [UNMATCHED; g.N1+g.N2]
    }


// Generate a human-readable string for a given matching.
// 
function toString(null|Matching m) -> (ascii::string s):
   if m is null:
      return "(no match)"
   else:
      ascii::string r = ""
      int i=0
      while i < |m.left|:
         if(i != 0):
            r = ascii::append(r,",")      
         ascii::string f = ascii::toString(i)
         ascii::string t = ascii::toString(m.left[i])
         r = ascii::append(r,f)
         r = ascii::append(r,"--")
         r = ascii::append(r,t)
         i = i + 1
      //
      return r

// Given a bipartite graph, can we find a matching of every vertex in
// one partiaion to a vertex in the second partition?  Each vertex in
// either partition can only be matched once.  For example, consider
// this easy case:
//
// A -- B
// C -- D
//
// Here, the first partition contains {A,C} and the second contains
// {B,D}.  The matching is then {A-B,C-D}.  In contrast, this does not
// match:
//
// A -- B
//    /
//   /
// C -- D
//    /
//   /
// E    F
//
// That's because we clearly don't have enough edges to pull this off. 
function findMaximalMatching(Graph g) -> (null|Matching r):
    //
    if g.N1 != g.N2:
        // No perfect matching possible
        return null
    else:
        // N1 == N2
        Matching m = Matching(g)
        bool matched
        int i = 0
        //
        while i < g.N1 where i >= 0
        // Every vertex below i is already matched
        where all { j in 0..i | m.left[j] != UNMATCHED }:
            bool[] visited = [false; g.N1]
            m,visited,matched = find(m,visited,i)
            if !matched:
                // no match for this vertex possible
                return null
            i = i + 1
        //
        return m

// Perform a depth-first search from a given vertex whilst attempting
// to find augmented paths for already matched vertices. For
// example, consider this graph:
//
// *A -- B*
//     /
//    /
//  C -- D
//     /
//    /
//  E -- F
//
// Support A and B are matched and we're traversing from C.  At first,
// we'll try to find an augmenting path for B.  In otherwords, try to
// find another match for B.  That will of course fail and we'll then
// try to match D and will succeed immediately.
function find(Matching m, bool[] visited, int from) -> (Matching r_m, bool[] r_visited, bool matched)
// If return true, then from was definitely matched
requires 0 <= from && from < |visited|
ensures matched ==> r_m.left[from] != UNMATCHED:
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
                return match(m,from,e.to), visited, true
            else if !visited[tor]:
                // to already matched; hence, try to find augmenting
                // path so it can be unmatched.
                m,visited,matched = find(m,visited,tor)
                if matched:
                    return match(m,from,e.to), visited, true
        i = i + 1
    //
    // Failed
    //
    return m,visited,false

// Update matching to record a match between from and to.  However, if
// source vertex was already matched against another vertex, then the
// status for the over vertex is updated (i.e. set to unmatched).
function match(Matching m, int from, int to) -> (Matching r)
// The target vertex cannot be matched; note, however,
// that the source vertex may already be matched
requires m.right[to] == UNMATCHED:
    //
    int l_from = m.left[from]
    //
    if l_from != UNMATCHED:
        // from was already matched
        m.right[l_from] = UNMATCHED
    //
    m.left[from] = to
    m.right[to] = from
    //
    return m
   

public export method main():
    final int A = 0
    final int B = 1
    final int C = 2
    final int D = 3
    final int E = 4
    final int F = 5
    //
    edge[] es = [ {from:A, to: D}, {from: B, to: D}, {from: B, to: E}, {from: C, to: F}, {from: C, to: E} ]
    //edge[] es = [ {from:A, to: B} ]
    Graph g = {N1:3, N2: 3, edges: es}
    // Try it out!
    null|Matching r = findMaximalMatching(g)
    // Done
    debug toString(r)
    debug "\n"