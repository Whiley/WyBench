import java.util.*;

public class Generator {

    public static final int N = 1000;
    public static String[] vars = {
	"p","q","r","s","t","u","v","w","x","y","z"
    };
    

    public static void main(String[] args) {
	Random random = new Random();

	// initialise all variables
	for(int i=0;i!=vars.length;++i) {
		System.out.print("set ");
		System.out.print(vars[i]);
		System.out.println(" 1");
	}
	for(int i=0;i!=N;++i) {
	    if(random.nextDouble() > 0.75) {
		// generate set statement
		System.out.print("set ");
		System.out.print(vars[random.nextInt(vars.length)]);
		System.out.print(" ");
		System.out.println(random.nextInt(1000000)+1);
	    } else {		
		System.out.print("print ");
		int nterms = random.nextInt(100)+1;
		for(int j=0;j<nterms;++j) {
		    if(j != 0) {
			switch(random.nextInt(4)) {
			case 0:
			    System.out.print("+");
			    break;
			case 1:
			    System.out.print("-");
			    break;
			case 2:
			    System.out.print("*");
			    break;
			case 3:
			    System.out.print("/");
			}
		    }	
		    System.out.print(vars[random.nextInt(vars.length)]);
		}
		System.out.println();
	    }
	}
    }
}
