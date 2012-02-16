package imagelib.bmp

import * from whiley.lang.*
import * from imagelib.bmp.BMP
import imagelib.core.RGBA
import imagelib.core.Image


public BMP ::readBMP([byte] data) throws Error:
	pos = 0
	// =========================
	// BMP FILE HEADER
	// =========================
	// | 2 | - Header Field. 
	// | 4 | - BMP Size in Bytes
	// | 2 | - Reserved for image creation application (Ignored in this reader)
	// | 2 | - Also Reserved for Application used (Ignored in this Reader)
	// | 4 | - Offset of the starting address of the pixel array
	magic = ""
	for i in 0..2:
		ch = Byte.toUnsignedInt(data[pos])
		pos = pos + 1
		magic = magic + (char)ch
	if magic [0..2] != "BM":
		throw Error("Invalid Header or unsupported BMP Format: " + magic)
	
	size = Byte.toUnsignedInt(data[pos..pos+4])
	pos = pos + 4
	pos = pos + 4 //We want to skip the two reserved blocks
	
	pixelArrayOffset = Byte.toUnsignedInt(data[pos..pos+4])
	pos = pos + 4
	bmpHeader = BMP.BMPHeader(size, pixelArrayOffset)
	
	// =========================
	// DIB HEADER (Bitmap Information Header)
	// =========================
	// | 4 | - Size of the header. (ALWAYS 40)
	// | 4 | - Bitmap Width in pixels (Signed Integer)
	// | 4 | - Bitmap Height in Pixels (Signed Integer)
	// | 2 | - Number of Colour Planes Used (ALWAYS 1)
	// | 2 | - Number of Bits per pixel
	// | 4 | - Compression Method being used 
	// | 4 | - Image Size (Size of raw bitmap data, excludes the headers, and for <=8 bit images, the table)
	// | 4 | - Horizontal Image Resolution (Pixel per Meter, Signed Int)
	// | 4 | - Vertical Image Resolution (Pixel per Meter, Signed Int)
	// | 4 | - Number of Colours in the Colour Palette
	// | 4 | - Number of Important colours used (Usually Ignored)
	
	headerSize = Byte.toUnsignedInt(data[pos..pos+4])
	pos = pos + 4
	if headerSize != 40:
		throw Error("Invalid Headersize. Expected 40, got: " + headerSize)
	
	width = Byte.toInt(data[pos..pos+4])
	pos = pos + 4
	height = Byte.toInt(data[pos..pos+4])
	pos = pos + 4
	colorPlanes = Byte.toUnsignedInt(data[pos..pos+2])
	pos = pos + 2
	if colorPlanes != 1:
		throw Error("Invalid Number of Colour Planes. Expected 1, got: " + colorPlanes)
	
	bitsPerPixel = Byte.toUnsignedInt(data[pos..pos+2])
	pos = pos + 2
	compressionMethod = Byte.toUnsignedInt(data[pos..pos+4])
	pos = pos + 4
	if compressionMethod != 0:
		throw Error("Compression of Images not supported")
		
	imageSize = Byte.toUnsignedInt(data[pos..pos+4])
	pos = pos + 4
	horizResolution =  Byte.toInt(data[pos..pos+4])
	pos = pos + 4
	verticalResolution = Byte.toInt(data[pos..pos+4])
	pos = pos + 4
	numColors = Byte.toUnsignedInt(data[pos..pos+4])
	pos = pos + 4
	importantColors = Byte.toUnsignedInt(data[pos..pos+4])
	pos = pos + 4
	
	dibHeader = BMP.DIBHeader(40, width, height, bitsPerPixel, imageSize)
	
	//data = [] OVERWRITTEN HERE
	array = []
	if bitsPerPixel <= 8:
		throw Error ("Images with less than 16 bpp not supported")
	else:
		paddingVal = 3*width
		blankBytes = paddingVal % 4
		if blankBytes != 0:
			blankBytes = 4 - blankBytes
		//Need to read in the data
		dataSize = height*width
		currWidth = 0
		for i in 0..dataSize:
			array = array + [Byte.toUnsignedInt(data[pos])] // Red
			array = array + [Byte.toUnsignedInt(data[pos+1])] // Green
			array = array + [Byte.toUnsignedInt(data[pos+2])] // Blue
			
			//THIS LINE CAUSES INTERNAL FAILURE. NEED TO FIGURE OUT WHY
			//Something to do with accidently overwriting the data array (I think)
			//value = RGBA((real)Byte.toUnsignedInt(data[pos]),(real)Byte.toUnsignedInt(data[pos+1]),(real)Byte.toUnsignedInt(data[pos+2]),0.0)
			//value = RGBA(red, green, blue, 0.0)
			pos = pos + 3
			//array = array+[value]
			currWidth = currWidth + 1
			if currWidth == width:
				pos = pos + blankBytes
				currWidth = 0
			
	
	return BMP.BMP(bmpHeader, dibHeader, array)