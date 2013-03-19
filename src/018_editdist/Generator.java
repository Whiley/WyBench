import java.util.*;

public class Generator {
    public static final int AMNT = 100;
    public static final int SECLENSM = 8;
    public static final int SECLENDF = 4;
    public static final int SECS = 4;

    public static String genStr(int l, Random rnd) {
        String res = "";
        if (l <= 0)
            return res;
        for (int i = 0; i != l; ++i) {
            res += String.format("%c", 'a' + rnd.nextInt('z' - 'a'));
        }
        return res;
    }

    public static void main(String[] args) {
        Random random = new Random(); 
        for(int i = 0; i != AMNT; ++i) {
            String w0 = "", w1 = "";
            for (int j = 0; j != SECS; ++j) {
                w0 += genStr(random.nextInt(SECLENDF), random);
                w1 += genStr(random.nextInt(SECLENDF), random);
                String sm = genStr(random.nextInt(SECLENSM), random);
                w0 += sm;
                w1 += sm;
            }
            w0 += genStr(random.nextInt(SECLENDF), random);
            w1 += genStr(random.nextInt(SECLENDF), random);
            System.out.print(w0 + " ");
            System.out.println(w1);
        }
    }
}

