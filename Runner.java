import java.lang.reflect.*;
import java.util.ArrayList;
import java.io.*;

// this class encapsulates all code necessary for timing
// and averaging benchmark tests.

public class Runner {
	final static PrintStream output = System.out;
	
	public static void main(String args[]) {
		int index = 0;
		int nRampUpRuns = 5;
		int nRuns = 10;					
				
		// parse command line parameters
		while (args[index].charAt(0) == '-') {
			String cmd = args[index].substring(0, 2);
			String optarg = args[index].substring(2, args[index].length());
			if (cmd.equals("-n")) {
				nRuns = Integer.parseInt(optarg);
			} else if (cmd.equals("-r")) {
				nRampUpRuns = Integer.parseInt(optarg);
			} else {
				throw new RuntimeException(
						"unrecognised command-line argument \"" + cmd + "\"");
			}
			index++;
			}
		
		try {
			// redirect I/O
			System.setOut(new PrintStream(new ByteArrayOutputStream()));			
			
			// Run Experiment
			ArrayList<Long> data = runExperiment(index,args,nRampUpRuns,nRuns);
			
			// Compute and print out statistical information
			writeStats(data);
		} catch (ClassNotFoundException e) {
			output.println("Error - unable to find class \"" + args[index]
					+ "\"");
		} catch (NoSuchMethodException e) {
			output.println("Error - benchmark \"" + args[index]
					+ "\" must provide main method.");
		} catch (NullPointerException e) {
			output.println("Error - null pointer exception");
		} catch (Exception e) {
			output.println("Internal error - " + e);
		}
	}

	public static void writeStats(ArrayList<Long> data) {
		double average = average(data);
		double standardDeviation = standardDeviation(average,data);
		double coefficientOfError = standardDeviation / average;		
		output.printf("%f\t%f\t%f", average,standardDeviation,coefficientOfError);
	}
	
	public static double average(ArrayList<Long> data) {
		double total = 0;
		for(long l : data) {
			total = total + l;
		}
		return total / data.size();
	}
	
	public static double standardDeviation(double average, ArrayList<Long> data) {
		double sdev = 0;
		for (Long l : data) {
			sdev += ((l - average) * (l - average));
		}
		sdev = sdev / data.size();
		sdev = Math.sqrt(sdev);
		return sdev;
	}
	
	public static ArrayList<Long> runExperiment(int index, String[] args,
			int nRampUpRuns, int nRuns) throws ClassNotFoundException,
			NoSuchMethodException {
		Class benchmark = Class.forName(args[index]);
		Method m = benchmark.getDeclaredMethod("main", args.getClass());
		// now build arguments
		String[] barg = new String[args.length - (index + 1)];
		for (int i = index + 1; i != args.length; ++i) {
			barg[i - (index + 1)] = args[i];
		}
		Object[] bargs = new Object[1];
		bargs[0] = barg;
		// ramp up runs
		for (int i = 0; i != nRampUpRuns; ++i) {
			exec(m,bargs);				
			// force garbage collection.
			System.gc();
		}
		ArrayList<Long> data = new ArrayList<Long>();
		for (int i = 0; i != nRuns; ++i) {
			data.add(exec(m,bargs));				
			// force garbage collection.
			System.gc();
		}
		return data;
	}
	
	public static long exec(final Method m, final Object[] bargs)  {									
		long start = System.currentTimeMillis();
		Thread currentThread = Thread.currentThread();		
		try {	
			m.invoke(null,bargs);						
		} catch(IllegalAccessException e) {					
		} catch(InvocationTargetException e) {										
		} 
		long total = System.currentTimeMillis() - start;
		return total;
	}
}
