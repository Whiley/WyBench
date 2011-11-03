public class Generator {

    public static final N = 100;

    public static void main(String[] args) {
	for(i=0;i!=N;++i) {
	    if(Math.random() > 0.5) {
		// generate set statement
		System.out.println("set")
	    } else {
		System.out.println("print")		
	    }
	}
    }
}