package lander.ui

/**
 * Fill a given rectangle on the canvas with a given color.
 */
native void ::fillRectangle(int x, int y, int width, int height):

export void ::dump(int x, int y, int width, int height):
	fillRectangle(x,y,width,height)
