import * from whiley.lang.Errors
import * from whiley.io.*
import * from whiley.lang.System
import imagelib.core.Image
import imagelib.png.*
import imagelib.gif.*
import imagelib.bmp.*

import zlib.io.GZip

// hacky test function
public void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
    contents = file.read()
    try:
        // gzip = GZip.decompress(contents)
        // sys.out.println(String.fromASCII(gzip.data))
        png = PNG.decode(contents)
        data = PNG.decompress(png)
        //image = GIF.toImage(gif,gif.images[0])
        //BMPEncoder.write(Image(image.width,image.height,image.data),"file.bmp")
    catch(Error e):
        sys.out.println("Error: " + e.msg)

