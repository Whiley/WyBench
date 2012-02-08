import Colour

define WIDTH as 512
define HEIGHT as 512

public void ::draw(int x, int y, Colour c):
    draw(x,y,c.red,c.green,c.blue)

public native void ::draw(int x, int y, Type.int8 r, Type.int8 g, Type.int8 b):
