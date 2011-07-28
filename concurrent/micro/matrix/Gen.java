import java.util.*;

public class Gen {
    public static final int n = 1000;

    public static int randNumber() {
	return (int) (Math.random() * 100);
    }
    
    public static void main(String[] args) {
	ArrayList<Integer> list = new ArrayList();
	System.out.println(n + " " + n);
	System.out.println("--");
	
	for(int i=0;i!=n;++i) {
	    for(int j=0;j!=n;++j) {
		System.out.print(randNumber() + " ");
	    }
	    System.out.println();
	}
	System.out.println("--");
	for(int i=0;i!=n;++i) {
	    for(int j=0;j!=n;++j) {
		System.out.print(randNumber() + " ");
	    }
	    System.out.println();
	}
    }
}
