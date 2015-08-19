import whiley.lang.*
import whiley.lang.Stack
import whiley.io.File
import char from whiley.lang.ASCII
import string from whiley.lang.ASCII

import wybench.Parser

type nat is (int x) where x >= 0

public type Stack is { // should be unnecessary
    int[] items,
    int length
}

// ============================================
// Adjacency List directed graph structure
// ============================================

type Digraph is (nat[][] edges)
    where all { i in 0..|edges|, j in 0..|edges[i]| | edges[i][j] < |edges| }

constant EMPTY_DIGRAPH is [[0;0];0]

function addEdge(Digraph g, nat from, nat to) -> Digraph:
    // First, ensure enough capacity
    int max = Math.max(from,to)
    g = resize(g,max+1)
    // Second, add the actual edge
    g[from] = Array.append(g[from],to)
    // Done
    return g

// Ensure graph has sufficient capacity
function resize(Digraph g, int size) -> (Digraph r)
ensures |r| == size:
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

function buildDigraphs(int[][] input) -> Digraph[]:
    //
    Digraph[] graphs = [EMPTY_DIGRAPH; |input|]
    int i = 0
    while i < |input|:
        graphs[i] = parseDigraph(input[i])
        i = i + 1
    //
    return graphs

function parseDigraph(int[] input) -> Digraph:
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
    Stack stack,
    int index,
    int cindex
}

function State(Digraph g) -> State:
    return {
        graph: g,
        visited: [false; |g|],
        inComponent: [false; |g|],
        rindex: [0; |g|],    
        stack: Stack.create(|g|),
        index: 0,
        cindex: 0
    }

function find_components(Digraph g) -> int[][]:
    State state = State(g)
    
    int i = 0
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
        components[cindex] = Array.append(components[cindex],i)
        i = i + 1
    //
    return components

function visit(int v, State s) -> State:
    bool root = true
    s.visited[v] = true
    s.rindex[v] = s.index
    s.index = s.index + 1
    s.inComponent[v] = false
    // process edges
    int i = 0
    while i < |s.graph[v]|:
        int w = s.graph[v][i]
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
        while Stack.size(s.stack) > 0 && rindex_v <= s.rindex[Stack.top(s.stack)]:
            int w = Stack.top(s.stack)
            s.stack = Stack.pop(s.stack)
            s.rindex[w] = s.cindex
            s.inComponent[w] = true
        s.rindex[v] = s.cindex
        s.cindex = s.cindex + 1
    else:
        s.stack = Stack.push(s.stack,v)
    // all done
    return s

method main(System.Console sys):
    File.Reader file = File.Reader(sys.args[0])
    string input = ASCII.fromBytes(file.readAll())
    int[][]|null data = Parser.parseIntLines(input)
    if data == null:
        sys.out.println_s("error parsing input")
    else:
        Digraph[] graphs = buildDigraphs(data)
        // third, print output
        int count = 0
        int i = 0 
        while i < |graphs|:
            Digraph graph = graphs[i]
            sys.out.print_s("=== Graph #")
            sys.out.print_s(Int.toString(i))
            sys.out.println_s(" ===")
            i = i + 1
            int[][] sccs = find_components(graph)
            int j = 0 
            while j < |sccs|:
                sys.out.print_s("{")
                bool firstTime=true
                int[] scc = sccs[j]
                int k = 0
                while k < |scc|:
                    if !firstTime:
                        sys.out.print_s(",")
                    firstTime=false
                    sys.out.print(scc[k])
                    k = k + 1
                sys.out.print_s("}")
                j = j + 1
            //        
            sys.out.println_s("")
