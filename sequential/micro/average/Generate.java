import java.util.*;

public class Generate {
    public static void main(String[] args) {
	Random random = new Random();
	for(int i=0;i!=10000;++i) {
	    System.out.println(random.nextDouble());
	}
    }
}
