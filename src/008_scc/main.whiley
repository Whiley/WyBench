import std::array
import std::ascii
import std::io
import std::math
import std::vector
import std::filesystem

import wybench::parser

type nat is (int x) where x >= 0

// ============================================
// Adjacency List directed graph structure
// ============================================

type Digraph is (nat[][] edges)
    where all { i in 0..|edges|, j in 0..|edges[i]| | edges[i][j] < |edges| }

Digraph EMPTY_DIGRAPH = [[0;0];0]

function addEdge(Digraph g, nat from, nat to) -> Digraph:
    // First, ensure enough capacity
    int max = math::max(from,to)
    g = resize(g,max+1)
    // Second, add the actual edge
    g[from] = array::append(g[from],to)
    // Done
    return g

// Ensure graph has sufficient capacity
function resize(Digraph g, int size) -> (Digraph r)
ensures |r| > size || (size >= |g| && |r| == size):
    //
    if size >= |g|:
        // Graph smaller than required
        Digraph ng = [[0;0]; size]
        nat i = 0
        while i < |g|:
            ng[i] = g[i]
            i = i + 1
        return ng
    else:
        // Graph already big enough
        return g

// ============================================
// Parser
// ============================================

function buildDigraphs(nat[][] input) -> Digraph[]:
    //
    Digraph[] graphs = [EMPTY_DIGRAPH; |input|]
    int i = 0
    while i < |input|:
        graphs[i] = parseDigraph(input[i])
        i = i + 1
    //
    return graphs

function parseDigraph(nat[] input) -> Digraph:
    //
    Digraph graph = EMPTY_DIGRAPH
    int i = 0
    //
    while (i+1) < |input|:
        int from = input[i]
        int to = input[i + 1]
        graph = addEdge(graph,from,to)
        i = i + 2
    //        
    return graph

// ============================================
// PEA_FIND_SCC1
// ============================================

// See: "An Improved Algorithm for Finding the Strongly Connected 
// Components of a Directed Graph", Information Processing Letters, 
// David J. Pearce, 2015.

type State is {
    Digraph graph,
    bool[] visited,
    bool[] inComponent,
    int[] rindex,
    vector::Vector<int> stack,
    int index,
    int cindex
}
where |visited| == |graph|
where |inComponent| == |graph|
where |rindex| == |graph|

function State(Digraph g) -> State:
    return {
        graph: g,
        visited: [false; |g|],
        inComponent: [false; |g|],
        rindex: [0; |g|],    
        stack: vector::Vector<int>(),
        index: 0,
        cindex: 0
    }

function find_components(Digraph g) -> int[][]:
    State state = State(g)
    
    nat i = 0
    while i < |g|:
        if !state.visited[i]:
            state = visit(i,state)
        i = i + 1
    
    // build componnent list
    int[][] components = [[0;0]; state.cindex]
    i = 0 
    //
    while i < |g|:
        int cindex = state.rindex[i]
        components[cindex] = array::append(components[cindex],i)
        i = i + 1
    //
    return components

function visit(nat v, State s) -> State
requires v < |s.graph|:
    bool root = true
    s.visited[v] = true
    s.rindex[v] = s.index
    s.index = s.index + 1
    s.inComponent[v] = false
    // process edges
    int i = 0
    while i < |s.graph[v]|:
        nat w = s.graph[v][i]
        if !s.visited[w]:
            s = visit(w,s)
        if !s.inComponent[w] && s.rindex[w] < s.rindex[v]:
            s.rindex[v] = s.rindex[w]
            root = false
        i = i + 1
    // check to see if we're a component root
    if root:
        s.inComponent[v] = true
        int rindex_v = s.rindex[v]
        while vector::size(s.stack) > 0 && rindex_v <= s.rindex[vector::top(s.stack)]:
            int w = vector::top(s.stack)
            s.stack = vector::pop(s.stack)
            s.rindex[w] = s.cindex
            s.inComponent[w] = true
        s.rindex[v] = s.cindex
        s.cindex = s.cindex + 1
    else:
        s.stack = vector::push(s.stack,v)
    // all done
    return s

method main(ascii::string[] args):
    filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
    ascii::string input = ascii::from_bytes(file.read_all())
    int[][]|null data = parser::parseIntLines(input)
    if data is nat[][]:
        Digraph[] graphs = buildDigraphs(data)
        // third, print output
        int count = 0
        int i = 0 
        while i < |graphs|:
            Digraph graph = graphs[i]
            io::print("=== Graph #")
            io::print(ascii::to_string(i))
            io::println(" ===")
            i = i + 1
            int[][] sccs = find_components(graph)
            int j = 0 
            while j < |sccs|:
                io::print("{")
                bool firstTime=true
                int[] scc = sccs[j]
                int k = 0
                while k < |scc|:
                    if !firstTime:
                        io::print(",")
                    firstTime=false
                    io::print(scc[k])
                    k = k + 1
                io::print("}")
                j = j + 1
            //        
            io::println("")
    else:
            io::println("error parsing input")

