import java.util.*;

public class Generator {
    private static final int LINES = 10;
    private static final int SECTIONS = 4;
    private static final int DEPTH = 3;
    private static final String[] ops = {"+", "-", "*", "/"};

    private static int genNumber(Random random) {
        return random.nextInt(0xff) + 1;
    }

    private static void genExpr(int dep, Random random) {
        System.out.print(genNumber(random));
        for (int i = 0; i != SECTIONS; ++i) {
            int op = genNumber(random) & 0x03;
            int dp = genNumber(random) & 0x01;
            System.out.print(ops[op]);
            if (dp == 0 && dep < DEPTH && op != 3) {
                System.out.print("(");
                genExpr(dep + 1, random);
                System.out.print(")");
            } else {
                System.out.print(genNumber(random));
            }
        }
    }

    public static void main(String[] args) {
        Random random = new Random();
        for (int i = 0; i != LINES; ++i) {
            genExpr(0, random);
            System.out.println("");
        }
    }
}
