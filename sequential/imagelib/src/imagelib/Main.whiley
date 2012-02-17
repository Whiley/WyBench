package imagelib

import * from whiley.lang.Errors
import * from whiley.io.*
import * from whiley.lang.System
import imagelib.core.Image
import imagelib.gif.*
import imagelib.bmp.*
import imagelib.transforms.*

// hacky test function
public void ::main(System.Console sys):
	file = File.Reader(sys.args[0])
	contents = file.read()
	try:
		//gif = GifDecoder.read(contents)
		//image = GIF.toImage(gif,gif.images[0])
		bmp = BMPDecoder.decode(contents)
		image = BMP.toImage(bmp)
		image = Transform.brighten(image, 3)
		//data = GifEncoder.encode(Image(image.width,image.height,image.data))
		data = BMPEncoder.encode(image)
		writer = File.Writer("file.bmp")
		writer.write(data)
		writer.close()
	catch(Error e):
		sys.out.println("Error: " + e)