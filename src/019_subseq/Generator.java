import java.util.*;

public class Generator {
    public static final int AMNT = 50;
    public static final int LEN = 250;
    public static final int MAX = 2000;
    public static final int SEC = 10;

    public static void main(String[] args) {
        Random random = new Random();
        for(int i = 0; i != AMNT; ++i) {
            for (int j = 0; j < LEN; j++) {
                System.out.print(MAX / SEC * (j / (LEN / SEC)) + random.nextInt(MAX / SEC));
                System.out.print(" ");
            }
            System.out.println("");
	}
    }
}

