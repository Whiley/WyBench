import java.util.*;

public class Generator {

    public static final int N = 100;

    public static void main(String[] args) {
	Random random = new Random();
	
	System.out.println("5");
	System.out.println(N + "x" + N);
	
	for(int i=0;i!=N;++i) {
	    for(int j=0;j!=N;++j) {
		if(random.nextDouble() > 0.75) {
		    // generate set statement
		    System.out.println(i + "," + j);
		}
	    }	    
	}
    }
}