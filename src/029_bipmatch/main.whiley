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
import std::array

int UNMATCHED = -1

// Every edge in our bipartite graph is from one side to the other.
type edge is { int from, int to }

type Graph is {
    int N1,      // size of first partition
    int N2,      // size of second partition
    edge[] edges // edges in graph
}
// Partitions are valid
where 0 <= N1 && N1 <= N2
// All edges are from a valid vertex
where all { i in 0..|edges| | 0 <= edges[i].from && edges[i].from < N1 }
// All edges are to a valid vertex
where all { i in 0..|edges| | N1 <= edges[i].to && edges[i].to < (N1+N2) }

type Matching is {
    Graph graph,
    int[] matching
}
// Matching must have enough space
where |matching| == (graph.N1+graph.N2)
// Every vertex is lower partion either unmatched (-1) or a valid vertex in upper partition
where all { i in 0..graph.N1 | matching[i] == UNMATCHED || (matching[i] >= graph.N1 && matching[i] < (graph.N1+graph.N2)) }
// Every vertex in upper partiaion either unmatched (-1) or a valid vertex in lower partition
where all { i in graph.N1..(graph.N1+graph.N2) | matching[i] >= UNMATCHED && matching[i] < graph.N1 }
// Every match is symmetric
where all { i in 0..graph.N1 | matching[i] == UNMATCHED || matching[matching[i]] == i }

// Simple constructor for matching
function Matching(Graph g) -> (Matching m)
ensures m.graph == g
// All vertices in both partitions unmatched
ensures all { i in 0..g.N1+g.N2 | m.matching[i] == UNMATCHED }:
    //
    return {
        graph: g,
        matching: [UNMATCHED; g.N1+g.N2]
    }


// Generate a human-readable string for a given matching.
// 
function to_string(null|Matching m) -> (ascii::string s):
   if m is null:
      return "(no match)"
   else:
      ascii::string r = ""
      int i=0
      while i < m.graph.N1:
         if(i != 0):
            r = array::append(r,",")      
         ascii::string f = ascii::to_string(i)
         ascii::string t = ascii::to_string(m.matching[i])
         r = array::append(r,f)
         r = array::append(r,"--")
         r = array::append(r,t)
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
        where all { j in 0..i | m.matching[j] != UNMATCHED }:
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
// Visited status needed for each vertex in lower partition
requires |visited| == m.graph.N1
// If return true, then from was definitely matched
requires 0 <= from && from < |visited|
// If something matched then from no longer unmatched
ensures matched ==> r_m.matching[from] != UNMATCHED:
    //
    Graph g = m.graph
    visited[from] = true
    //
    int i = 0
    //
    while i < |g.edges| where i >= 0 && |visited| == m.graph.N1:
        edge e = g.edges[i]
        if e.from == from:
            int tor = m.matching[e.to]
            if tor == UNMATCHED:
                // to is unmatched; hence, greedily match it
                return match(m,e), visited, true
            else if !visited[tor]:
                // to already matched; hence, try to find augmenting
                // path so it can be unmatched.
                m,visited,matched = find(m,visited,tor)
                if matched:
                    return match(m,e), visited, true
        i = i + 1
    //
    // Failed
    //
    return m,visited,false

// Update matching to record a match between from and to.  However, if
// source vertex was already matched against another vertex, then the
// status for the over vertex is updated (i.e. set to unmatched).
function match(Matching m, edge e) -> (Matching r)
// Edge must existing in graph
requires some { i in 0..|m.graph.edges| | m.graph.edges[i] == e }
// The target vertex cannot be matched; note, however,
// that the source vertex may already be matched
requires m.matching[e.to] == UNMATCHED:
    //
    int[] m_matching = m.matching
    //
    int l_from = m_matching[e.from]
    //
    if l_from != UNMATCHED:
        // from was already matched
        m_matching[l_from] = UNMATCHED
    //
    m_matching[e.from] = e.to
    m_matching[e.to] = e.from
    //
    return { graph: m.graph, matching: m_matching }


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
    debug to_string(r)
    debug "\n"