import java.util.*;

public class Generator {
    public static final int DM = 256;

    public static void main(String[] args) {
        Random random = new Random(); 
        System.out.println(String.format("%d %d", DM, DM));
        System.out.println(String.format("--------"));
        for(int i = 0; i != DM; ++i) {
            for(int j = 0; j != DM; ++j) {
                System.out.print(random.nextInt(0x100));
                System.out.print(" ");
            }
            System.out.println("");
        }
        System.out.println(String.format("--------"));
        for(int i = 0; i != DM; ++i) {
            for(int j = 0; j != DM; ++j) {
                System.out.print(random.nextInt(0x100));
                System.out.print(" ");
            }
            System.out.println("");
        }
    }
}

