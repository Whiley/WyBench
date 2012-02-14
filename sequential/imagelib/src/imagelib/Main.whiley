import * from whiley.lang.Errors
import * from whiley.io.*
import * from whiley.lang.System
import Image

// hacky test function
public void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
    contents = file.read()
    try:
        gif = GifDecoder.read(contents)
        image = gif.images[0]
        for i in 0..image.height:
            for j in 0..image.width:
                debug "" + image.data[(j*image.width)+i]
            debug "\n"
        //BMP.write(Image(image.width,image.height,image.data),"file.bmp")
    catch(Error e):
        sys.out.println("Error: " + e)
    
