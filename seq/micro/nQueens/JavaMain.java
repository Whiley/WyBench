import java.util.*;

public class JavaMain {
    
    /**
     * Pos is a simple representation of a position on the board
     */
    public static final class Pos {
	final int row,col; // range 0..7

	public Pos(int row, int col) {
	    this.row = row;
	    this.col = col;
	}

	public boolean conflict(int row, int col) {
	    if(this.row == row || this.col == col) {
		return true;
	    }
	    int colDiff = Math.abs(this.col - col);
	    int rowDiff = Math.abs(this.row - row);
	    return colDiff == rowDiff;
	}
    }

    // debugging code
    public static void printBoard(Pos[] queens, int n, int dim) {
	System.out.print(" ");
	for(int col=0;col < dim;++col) {
	    System.out.print(" "+ col);
	}
	System.out.println();
	for(int row=0;row < dim;++row) {
	    System.out.print(" +");
	    for(int col=0;col < dim;++col) {
		System.out.print("-+");
	    }
	    System.out.println();
	    System.out.print(row + "|");
	    for(int col=0;col < dim;++col) {
		boolean matched = false;
		for(int i=0;i < n;++i) {
		    Pos queen = queens[i];
		    if(row == queen.row && col == queen.col) {
			matched=true;
			break;
		    }
		}	
		if(matched) {
		    System.out.print("Q|");
		} else {
		    System.out.print(" |");
		}
	    }
	    System.out.println();
	}
	System.out.print(" +");
	for(int col=0;col < dim;++col) {
	    System.out.print("-+");
	}
	System.out.println();
	System.out.println();
    }

    /**
     * Place a queen on the board, using the given dimension as the
     * search parameter.
     */
    public static void run(Pos[] queens, int n, int dim, ArrayList<Pos[]> solutions) {
	//printBoard(queens,n,dim);
	if(dim == n) {
	    // solution
	    solutions.add(queens.clone());
	} else {
	    for(int col=0;col<dim;++col) {
		boolean solution = true;
		for(int i=0;i!=n;++i) {
		    Pos p = queens[i];			
		    if(p.conflict(n,col)) {
			solution = false;
			break;
		    }
		}
		if(solution) {
		    queens[n] = new Pos(n,col);
		    run(queens,n+1,dim,solutions);
		    queens[n] = null; // safety
		}
	    }
	}
    }    

    public static void main(String[] args) {
	int dim = 10;
	ArrayList<Pos[]> solutions = new ArrayList<Pos[]>();
	run(new Pos[dim],0,dim,solutions);
	System.out.println("Found " + solutions.size() + " solutions.");
    }
}
