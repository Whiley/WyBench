import java.math.BigInteger;
import java.lang.Thread;

/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public class Thread$native {
 
  public static void sleep(BigInteger ms) {
	  try {
		  Thread.sleep(ms.longValue());
	  } catch(Exception e) {}
  }
}
   