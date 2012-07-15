package roads;

import java.util.*;

// Random graph generator
public class Generate {
    public static void main(String args[]) { 
	HashSet<Edge> E = new HashSet();

	int ncities = Integer.parseInt(args[0]);
	int nroads = Integer.parseInt(args[1]);

	String names[] = new String[ncities];

	for(int i=0;i!=ncities;++i) {
	    names[i] = "CITY#" + Integer.toString(i);
	}

	System.err.println(names.length + " cities in network");

	for(int i=0;i!=nroads;++i) {
	    // each road max 100 miles
	    int dist = (int) (Math.random() * 100);
	    int from = (int) (Math.random() * names.length);
	    int to = (int) (Math.random() * names.length);
	    if(E.add(new Edge(names[from],names[to]))) {
		System.out.println(names[from] + "\t" + names[to] + "\t" + dist);
	    }
	}
    }
    
    private static class Edge {
	private String from;
	private String to;
	
	public Edge(String f, String t) {
	    from = f;
	    to = t;
	}

	public int hashCode() {
	    return from.hashCode() + to.hashCode();
	}

	public boolean equals(Object o) {
	    Edge e = (Edge) o;
	    return from == e.from && to == e.to;
	}
    }
}
