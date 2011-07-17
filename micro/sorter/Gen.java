import java.util.*;

public class Gen {
    public static void main(String[] args) {
	ArrayList<Integer> list = new ArrayList();
	for(int i=0;i!=10000;++i) {
	    list.add(i);
	}
	Collections.shuffle(list);
	for(int i : list) {
	    System.out.print(i + " ");
	}
	System.out.println();
    }
}
