package roads;

import java.util.*;
import java.io.*;

public class JavaMain {

    public final static class Graph {
	private HashMap<Integer, HashSet<Integer>> edges = new HashMap<Integer,HashSet<Integer>>();
	
	public void add(int from, int to) {
	    HashSet<Integer> rs = edges.get(from);
	    // now do forward direction
	    if(rs == null) {
		rs = new HashSet<Integer>();
		edges.put(from,rs);
	    }
	    rs.add(to);
	    // now do reverse direction
	    rs = edges.get(to);
	    if(rs == null) {
		rs = new HashSet<Integer>();
		edges.put(to,rs);
	    }
	    rs.add(from);
	}
	
	public HashSet<Integer> edges(Integer c){
	    ArrayList<Road> r = edges.get(c);
	    if(r == null) { r = new ArrayList<Road>(); }
	    return (ArrayList<Road>) r.clone();
	}	
    }

    public static final class Parser {
	private final String input;
	private int pos;
	
	public Parser(String input) {
	    this.input = input;
	    this.pos = 0;			
	}

	public int[] parse() {
	    ArrayList<Integer> rs = new ArrayList<Integer>();
	    skipWhiteSpace();
	    while(pos < input.length()) {
		int i = parseInt();
		rs.add(i);
		skipWhiteSpace();
	    }
	    int[] is = new int[rs.size()];
	    for(int i=0;i!=is.length;++i) {
		is[i] = rs.get(i);
	    }
	    return is;
	}
	
	public int parseInt() {
	    int start = pos;
	    while (pos < input.length() && Character.isDigit(input.charAt(pos))) {
		pos = pos + 1;
	    }
	    return Integer.parseInt(input.substring(start, pos));
	}
	
	public void skipWhiteSpace() {
	    while (pos < input.length()
		   && (input.charAt(pos) == ' ' || input.charAt(pos) == '\t')) {
		pos = pos + 1;
	    }
	}
    }

    public static Graph readFile(String filename) throws IOException {
	BufferedReader reader = new BufferedReader(new FileReader(filename));
	return new Parser(reader.readLine()).parse();
    }

    public static int findShortestRoute(City from, City to, Graph roads){
	HashMap<City,Distance> E = new HashMap<City,Distance>();	
	PriorityQueue<Distance> Q = new PriorityQueue();

	// ------- Initialise Q ------
	Distance d = new Distance(0,from);
	E.put(from,d);
	Q.add(d);	

	// ------- Perform Relaxation ------
	while(!Q.isEmpty()) {
	    Distance u = Q.poll();
	    if(u.city.equals(to)) { return u.distance; }

	    List<Road> outEdges;
	    outEdges = roads.edges(u.city); 

	    for(Road r : outEdges) {
		int n = u.distance + r.distance;
		Distance c = E.get(r.to);
		if(c == null) {
		    // null indicates infinite distance
		    c = new Distance(n,r.to);
		    E.put(r.to,c);
		    Q.add(c);
		} else if(n < c.distance) {
		    Q.remove(c);
		    c.distance = n;
		    Q.add(c);
		}
	    }
	} 

	return -1;
    }

    static final private class Distance implements Comparable<Distance> {
	public int distance;
	public City city;  
	
	public Distance(int t, City c) {
	    distance=t; city=c;
	}
    
	public int compareTo(Distance o) {
	    if(distance < o.distance) { return -1; }
	    else if(distance > o.distance) { return 1; }
	    else return city.compareTo(o.city);
	}
    }

    public static void main(String[] args) {	
	int size = Integer.parseInt(args[2]);	
	Random random = new Random();

	// --- READ INPUT FILE ---
	ArrayList<Road> roads = new ArrayList<Road>();
	City cities[] = parseFile(readFile(args[3]),roads);

	Graph graph;
	graph = new AdjacencyList(roads);

	// Now, compute shortest route from every city?
	int count = 0;
	for(int i=0;i!=size;++i) {
	    City from = cities[random.nextInt(cities.length)];
	    City to = cities[random.nextInt(cities.length)];
	    int distance = findShortestRoute(from,to,graph,limitMode);
	    if(distance < 0) {
		System.out.println("There is no route from " + from + " to " + to + ".");	   
	    } else {
		count = count + 1;
		System.out.println("Shortest Route from " + from + " to " + to +" is " + distance + " miles");
	    }
	}     
    }

}
