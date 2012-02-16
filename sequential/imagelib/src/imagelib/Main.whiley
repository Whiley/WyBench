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
		gif = GifDecoder.read(contents)
		image = GIF.toImage(gif,gif.images[0])
		
		data = GifEncoder.encode(Image(image.width,image.height,image.data))
		writer = File.Writer("file.gif")
		writer.write(data)
		writer.close()
	catch(Error e):
		sys.out.println("Error: " + e)