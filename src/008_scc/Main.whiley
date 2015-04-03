import whiley.io.File
import whiley.lang.System

import wybench.Parser

import char from whiley.lang.ASCII
import string from whiley.lang.ASCII
type nat is (int x) where x >= 0

// ============================================
// Adjacency List directed graph structure
// ============================================

type Digraph is ([{nat}] edges)
    where no { v in edges, w in v | w >= |edges| }

function addEdge(Digraph g, nat from, nat to) -> Digraph:
    // first, ensure enough capacity
    nat mx = Math.max(from,to)
    while |g| <= mx:
        g = g ++ [{}]
    //
    assume from < |g|
    // second, add the actual edge
    g[from] = g[from] + {to}        
    return g

// ============================================
// Parser
// ============================================

function buildDigraphs([int] input) -> [Digraph]:
    //
    [Digraph] graphs = []
    Digraph graph
    int pos = 0
    while pos < |input|:
        graph,pos = parseDigraph(pos,input)
        graphs = graphs ++ [graph]
    return graphs

function parseDigraph(int pos, [int] input) -> (Digraph,int):
    //
    Digraph graph = []
    int numEdges = input[pos]
    int i = 0
    pos = pos + 1
    //
    while i != numEdges:
        int from = input[pos]
        int to = input[pos + 1]
        graph = addEdge(graph,from,to)
        pos = pos + 1
        i = i + 1
    //        
    return graph,pos

// ============================================
// PEA_FIND_SCC1
// ============================================

// See: "An Improved Algorithm for Finding the Strongly Connected 
// Components of a Directed Graph", David J. Pearce, 2005.

type State is {
    Digraph graph,
    [bool] visited,
    [bool] inComponent,
    [int] rindex,
    [int] stack,
    int index,
    int cindex
}

function State(Digraph g) -> State:
    return {
        graph: g,
        visited: List.create(|g|,false),
        inComponent: List.create(|g|,false),
        rindex: List.create(|g|,0),    
        stack: [],
        index: 0,
        cindex: 0
    }

function find_components(Digraph g) -> [{int}]:
    State state = State(g)
    
    for i in 0..|g|:
        if !state.visited[i]:
            state = visit(i,state)
    
    // build componnent list
    [{int}] components = []
    while |components| < state.cindex:
        components = components ++ [{}]
    
    for i in 0..|g|:
        int cindex = state.rindex[i]
        components[cindex] = components[cindex] + {i}        
    
    return components

function visit(int v, State s) -> State:
    bool root = true
    s.visited[v] = true
    s.rindex[v] = s.index
    s.index = s.index + 1
    s.inComponent[v] = false
    // process edges
    for w in s.graph[v]:
        if !s.visited[w]:
            s = visit(w,s)
        if !s.inComponent[w] && s.rindex[w] < s.rindex[v]:
            s.rindex[v] = s.rindex[w]
            root = false
    // check to see if we're a component root
    if root:
        s.inComponent[v] = true
        int rindex_v = s.rindex[v]
        while |s.stack| > 0 && rindex_v <= s.rindex[Stack.top(s.stack)]:
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
    [int]|null data = Parser.parseInts(input)
    if data == null:
        sys.out.println_s("error parsing input")
    else:
        [Digraph] graphs = buildDigraphs(data)
        // third, print output
        int count = 0
        for graph in graphs:
            sys.out.println_s("=== Graph #" ++ Int.toString(count) ++ " (" ++ Int.toString(|graph|) ++ " nodes) ===")
            count = count + 1
            
            [{int}] sccs = find_components(graph)
            for scc in sccs:
                sys.out.print("{")
                bool firstTime=true
                for v in scc:
                    if !firstTime:
                        sys.out.print(",")
                    firstTime=false
                    sys.out.print(v)
                sys.out.print("}")
            //        
            sys.out.println("")
