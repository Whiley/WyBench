import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*
import * from whiley.lang.Errors

define nat as int where $ >= 0

// ============================================
// Adjacency List directed graph structure
// ============================================

define Digraph as [{nat}] where no { v in $, w in v | w >= |$| }

Digraph addEdge(Digraph g, nat from, nat to):
    // first, ensure enough capacity
    mx = Math.max(from,to)
    while |g| <= mx:
        g = g + [{}]
    //
    assume from < |g|
    // second, add the actual edge
    g[from] = g[from] + {to}        
    return g

// ============================================
// Parser
// ============================================

[Digraph] parseDigraphs(string input) throws SyntaxError:
    graphs = []
    pos = 0
    while pos < |input|:
        graph,pos = parseDigraph(pos,input)
        graphs = graphs + [graph]
    return graphs

(Digraph,int) parseDigraph(int pos, string input) throws SyntaxError:
    graph = []
    pos = match("{",pos,input)
    firstTime = true
    while pos < |input| && input[pos] != '}':
        if !firstTime:
            pos = match(",",pos,input)
        firstTime=false
        from,pos = parseInt(pos,input)
        pos = match(">",pos,input)
        to,pos = parseInt(pos,input)
        graph = addEdge(graph,from,to)
    pos = match("}",pos,input)    
    pos = skipWhiteSpace(pos,input) // parse any newline junk
    return graph,pos

int match(string match, int pos, string input) throws SyntaxError:
    end = pos + |match|
    if end < |input|:
        tmp = input[pos..end]
        if tmp == match:
            return end
        else:
            throw SyntaxError("expected " + match + ",found " + tmp,pos,end)
    else:
        throw SyntaxError("unexpected end-of-file",pos,end)

(int,int) parseInt(int pos, string input) throws SyntaxError:
    start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return Int.parse(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ============================================
// PEA_FIND_SCC1
// ============================================

// See: "An Improved Algorithm for Finding the Strongly Connected 
// Components of a Directed Graph", David J. Pearce, 2005.

define State as {
    Digraph graph,
    [bool] visited,
    [bool] inComponent,
    [int] rindex,
    [int] stack,
    int index,
    int cindex
}

State State(Digraph g):
    return {
        graph: g,
        visited: List.create(|g|,false),
        inComponent: List.create(|g|,false),
        rindex: List.create(|g|,0),    
        stack: [],
        index: 0,
        cindex: 0
    }

[{int}] find_components(Digraph g):
    state = State(g)
    for i in 0..|g|:
        if !state.visited[i]:
            state = visit(i,state)
    // build componnent list
    components = []
    while |components| < state.cindex:
        components = components + [{}]
    for i in 0..|g|:
        cindex = state.rindex[i]
        components[cindex] = components[cindex] + {i}        
    return components

State visit(int v, State s):
    root = true
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
        rindex_v = s.rindex[v]
        while |s.stack| > 0 && rindex_v <= s.rindex[Stack.top(s.stack)]:
            w = Stack.top(s.stack)
            s.stack = Stack.pop(s.stack)
            s.rindex[w] = s.cindex
            s.inComponent[w] = true
        s.rindex[v] = s.cindex
        s.cindex = s.cindex + 1
    else:
        s.stack = Stack.push(s.stack,v)
    // all done
    return s

void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
    input = String.fromASCII(file.read())
    try:
        graphs = parseDigraphs(input)
        // third, print output
        count = 0
        for graph in graphs:
            sys.out.println("=== Graph #" + count + " (" + |graph| + " nodes) ===")
            count = count + 1
            sccs = find_components(graph)
            for scc in sccs:
                sys.out.print("{")
                firstTime=true
                for v in scc:
                    if !firstTime:
                        sys.out.print(",")
                    firstTime=false
                    sys.out.print(v)
                sys.out.print("}")
            sys.out.println("")
    catch(SyntaxError e):
        sys.out.println("error: " + e.msg)
