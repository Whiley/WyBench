import java.util.*;

public class Generator {
    public static final int AMNT = 20;
    public static final int LEN = 7;
    public static final int DEP = 7;
    public static final int STRWTH = 10;

    public static String genString(Random random) {
        String res = "\"";
        int width = 1 + random.nextInt(STRWTH);
        for (int i = 0; i < width; i++)
            res += String.format("%c", 'a' + random.nextInt('z' - 'a'));
        res += "\"";
        return res;
    }

    public static String genValue(Random random, int lev) {
        int cs;
        String res;
        if (lev < DEP)
            cs = 6;
        else
            cs = 4;
        switch (random.nextInt(cs)) {
        case 0:
            res = genString(random);
            break;
        case 1:
            res = "true";
            break;
        case 2:
            res = "false";
            break;
        case 3:
            res = String.format("%d", random.nextInt(0x10000));
            break;
        case 4:
            res = genObject(random, lev + 1);
            break;
        case 5:
            res = genArray(random, lev + 1);
            break;
        default:
            res = "\"\"";
            break;
        }
        return res;
    }

    public static String genObject(Random random, int lev) {
        String res = "{";
        for (int i = 0; i < LEN; i++)
            res += genString(random) + ":" + genValue(random, lev + 1) + ",";
        res += genString(random) + ":" + genValue(random, lev + 1) + "}";
        return res;
    }

    public static String genArray(Random random, int lev) {
        String res = "[";
        for (int i = 0; i < LEN; i++) {
            res += genValue(random, lev);
            res += ",";
        }
        res += genValue(random, lev) + "]";
        return res;
    }

    public static void main(String[] args) {
        Random random = new Random();
        for(int i = 0; i < AMNT; ++i)
            System.out.println(genObject(random, 0));
    }
}

