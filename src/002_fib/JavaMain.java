public class JavaMain {
    public static int fib(int x) {
	if(x <= 1) {
	    return 1;
	} else {
	    return fib(x-1) + fib(x-2);
	}
    }
    public static void main(String[] args) {
	for(int i=1;i<=40;++i) {
	    System.out.println(fib(i));
	}
    }
}