import java.util.*;
import java.io.*;

public class JavaMain {

    // A directed graph
    public static final class Digraph {
	private final ArrayList<HashSet<Integer>> edges;
	private int nedges = 0;
	
	public Digraph() {
	    edges = new ArrayList();
	}
	
	public void add(int from, int to) {
		while (from >= edges.size() || to >= edges.size()) {
			edges.add(new HashSet());		
		}
		
		if(edges.get(from).add(to)) {
			nedges++;
		} 
	}
	
	public int numEdges() { return nedges; }
	public int size() { return edges.size(); }
		
	public Set<Integer> edges(int v) {
		return edges.get(v);
	}
	
	public String toString() {
		String r = "";
		for(int i=0;i!=edges.size();++i) {
			for(int j : edges.get(i)) {
			    r += i + "->" + j + " ";
			}
		}
		return r;
	}
    }

    public static final class Parser {
	private final String input;
	private int pos;
	
	public Parser(String input) {
	    this.input = input;
	    this.pos = 0;			
	}

	public Digraph parse() {
	    Digraph g = new Digraph();
	    boolean firstTime=true;
	    while(pos < input.length()) {
		if(!firstTime) {
		    match(",");
		}
		firstTime=false;
		int from = parseInt();
		match(">");
		int to = parseInt();
		g.add(from,to);
	    }
	    return g;
	}

	public void match(String r) {
	    if((pos + r.length()) < input.length()) {
		String tmp = input.substring(pos,pos+r.length());
		if(tmp.equals(r)) {
		    pos += r.length();
		    return; // match
		}
		throw new RuntimeException("Expecting " + r + ", found " + tmp);
	    }
	    throw new RuntimeException("Unexpected end-of-file");
	}

	public int parseInt() {
	    int start = pos;
	    while (pos < input.length() && Character.isDigit(input.charAt(pos))) {
		pos = pos + 1;
	    }
	    return Integer.parseInt(input.substring(start, pos));
	}	
    }

    /**
     * See the following paper for details of how this algorithm
     * works:
     * 
     * "An Improved Algorithm for Finding the Strongly Connected
     *  Components of a Directed Graph", David J. Pearce, 2005.
     */
    public static class PeaFindScc1 {
	private Digraph graph;
	private BitSet visited;
	private BitSet inComponent;
	private int[] rindex;
	private Stack<Integer> S;
	private int index;
	private int c; // component number

	public PeaFindScc1(Digraph g) {
	    this.graph = g;
	    this.visited = new BitSet(g.size());
	    this.inComponent = new BitSet(g.size());
	    this.rindex = new int[g.size()];
	    this.S = new Stack();
	    this.index = 0;
	    this.c = 0;
	}

	public HashSet<Integer>[] visit() {
	    for(int i=0;i!=graph.size();++i) {
		if(!visited.get(i)) {
		    visit(i);
		}
	    }
	    // now, post process to produce component sets
	    HashSet<Integer>[] components = new HashSet[c];
	    for(int i=0;i!=rindex.length;++i) {
		int cindex = rindex[i];
		HashSet<Integer> component = components[cindex];
		if(component == null) {
		    component = new HashSet<Integer>();
		    components[cindex] = component;
		}
		component.add(i);
	    }
	    return components;
	}

	public void visit(int v) {
	    boolean root = true;
	    visited.set(v,true);
	    rindex[v] = index++;
	    inComponent.set(v,false);
	    
	    for(int w : graph.edges(v)) {
		if(!visited.get(w)) {
		    visit(w);
		}
		if(!inComponent.get(w) && rindex[w] < rindex[v]) {
		    rindex[v] = rindex[w];
		    root = false;
		}
	    }

	    if(root) {
		inComponent.set(v,true);
		int rindex_v = rindex[v];
		while(!S.isEmpty() && rindex_v <= rindex[S.peek()]) {
		    int w = S.pop();
		    rindex[w] = c;
		    inComponent.set(w,true);
		}
		rindex[v] = c;
		c = c + 1;
	    } else {
		S.push(v);
	    }
	}
    }

    public static List<Digraph> readFile(String filename) throws IOException {
	BufferedReader reader = new BufferedReader(new FileReader(filename));
	ArrayList<Digraph> graphs = new ArrayList();
	while(reader.ready()) {
	    String input = reader.readLine();
	    if(!input.equals("")) {
		graphs.add(new Parser(input).parse());
	    }
	}
	return graphs;
    }

    public static void main(String[] args) {
	try {
	    int count = 0;
	    for(Digraph graph : readFile(args[0])) {
		System.out.println("=== Graph #" + count++ + " ===");
		PeaFindScc1 pscc = new PeaFindScc1(graph);
		for(HashSet<Integer> component : pscc.visit()) {
		    ArrayList<Integer> tmp = new ArrayList<Integer>(component);
		    Collections.sort(tmp);
		    System.out.print("{");
		    for(int i=0;i!=tmp.size();++i) {
			if(i != 0) {
			    System.out.print(", ");
			}
			System.out.print(tmp.get(i));
		    }
		    System.out.println("}");		    
		}
	    }
	} catch(IOException e) {
	    e.printStackTrace();
	}
    }
}
