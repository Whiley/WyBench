package lander.ui

/**
 * Fill a given rectangle on the canvas with a given color.
 */
native void ::fillRectangle(int x, int y, int width, int height):

/**
 * This method is called from the SimpleCanvas paint() method, 
 * and signals that the game canvas should be redrawn.
 */
export void ::paint():
	fillRectangle(0,0,10,10)
	
	
