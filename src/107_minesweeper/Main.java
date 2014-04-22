import minesweeper.logic.*;
import minesweeper.ui.*;

public class Main {	
    public static void main(String[] args) {
	Board b = new Board(10,10);
	GameFrame f = new GameFrame(b);
    }
}
