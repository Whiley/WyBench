import java.math.BigInteger;
import java.util.Random;
/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */


public class Random$native {

   public static java.math.BigInteger getRandomInt(BigInteger max) {
    int ret = new Random().nextInt(max.intValue());
    return new BigInteger(Integer.toString(ret));
  
  }

}