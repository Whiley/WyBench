package imagelib

import * from whiley.lang.Errors
import * from whiley.io.*
import * from whiley.lang.System
import imagelib.core.Image
import imagelib.gif.*
import imagelib.bmp.*

// hacky test function
public void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
    contents = file.read()
    try:
        gif = GIF.decode(contents)
        image = GIF.toImage(gif,gif.images[0])
        BMP.write(Image(image.width,image.height,image.data),"file.bmp")
    catch(Error e):
        sys.out.println("Error: " + e)
    
