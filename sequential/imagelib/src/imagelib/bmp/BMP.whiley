package imagelib.bmp

import * from whiley.lang.*
import * from whiley.io.File
import imagelib.core.RGBA
import imagelib.core.Image

public void ::write(Image img, string filename):
	writer = File.Writer(filename)
	//Write out Magic Header
	writer.write([01000010b, 01001101b]) // "BM"
	paddingVal = 3*img.width //This is the width of a row in bytes.
	
	//The total width of a row in the BMP format must be a multiple of Four. 
	blankBytes = paddingVal % 4
	if blankBytes != 0:
		blankBytes = 4 - blankBytes
	size = 54 + 3*(img.height * img.width) + (blankBytes * img.height)
	
	writer.write(padUnsignedInt(size,4)) //Total Size of the BMP file, including header information
	writer.write(padUnsignedInt(0, 4)) // Two reserved 2 byte blocks. The values can be used for whatever the creation software wants. Leave blank
	writer.write(padUnsignedInt(54, 4)) // Offset of the Pixel array (Always 54, 14 byte file header, 40 byte Information Header)

	//Finished Writing Data Header. Writing Info Header
	writer.write(padUnsignedInt(40, 4)) // Header Size
	writer.write(padUnsignedInt(img.width, 4)) //Width	
	writer.write(padUnsignedInt(img.height, 4)) //Height
	writer.write(padUnsignedInt(1, 2)) //Color Planes (MUST BE ONE)

	writer.write(padUnsignedInt(24, 2)) // Bit Depth
	writer.write(padUnsignedInt(0, 4)) // Compression Value
	writer.write(padUnsignedInt(size - 54, 4)) // Size of raw Bitmap Data
	writer.write(padUnsignedInt(2834, 4)) // Horizontal Resolution
	writer.write(padUnsignedInt(2834, 4))	// Vertical Resolution
	writer.write(padUnsignedInt(0, 4)) 
	writer.write(padUnsignedInt(0, 4)) //Important Colours used. This is generally ignored
	
	currWidth = 0
	imageData = []
	currRow = []
	for col in img.data:
		currRow = currRow + [Int.toUnsignedByte(Math.round(col.blue*255))]
		currRow = currRow + [Int.toUnsignedByte(Math.round(col.green*255))]
		currRow = currRow + [Int.toUnsignedByte(Math.round(col.red*255))]
		currWidth = currWidth + 1
		if currWidth == img.width:
			currWidth = 0
			if blankBytes != 0:
				imageData = imageData + padUnsignedInt(0, blankBytes)
			imageData = currRow + imageData
			currRow = []
	
	writer.write(imageData)
	writer.close()

public int getBitDepth(Image img, [int] potential):
    numColors = getDistinctColors(img)
    debug "Number of Distinct Colours: " + numColors + "\n"
    for i in potential:
        if Math.pow(2, i) >= numColors:
            return i
    return -1

[byte] padUnsignedInt(int i, int padLength):
	data = Int.toUnsignedBytes(i)
	
	for j in |data|..padLength:
		data = data + [00000000b]
	return data

int getDistinctColors(Image img):
    table = {}
    for col in img.data:
        table = table + {col}
    return |table|

public Image ::readBMP(Reader file):
	debug "Reading Bitmap File\n"
	size = Byte.toUnsignedInt(file.read(4))
	file.read(4) // Skip the two application Reserved Blocks
	pixelArrayOffset = Byte.toUnsignedInt(file.read(4))
	
	//Reading the Information Header
	//This Contains Size, resolution, bpp, compression and color information
	headerSize = Byte.toUnsignedInt(file.read(4))
	assert headerSize == 40 //No reason this would ever fail, except if corrupt
	
	DIBInfo = file.read(36) // Read the rest of the 40 byte header, minus the information already read
	width = Byte.toInt(DIBInfo[0..3])
	height = Byte.toInt(DIBInfo[4..7])
	colorPlanes = Byte.toUnsignedInt(DIBInfo[8..9])
	assert colorPlanes == 1
	//Not Doing Anything with this information
	
	bitsPerPixel = Byte.toUnsignedInt(DIBInfo[10..11])
	compressionMethod = Byte.toUnsignedInt(DIBInfo[12..15])
	imageSize = Byte.toUnsignedInt(DIBInfo[16..19])
	horizResolution =  Byte.toInt(DIBInfo[20..23])
	verticalResolution = Byte.toInt(DIBInfo[24..27])
	numColors = Byte.toUnsignedInt(DIBInfo[28..31])
	importantColors = Byte.toUnsignedInt(DIBInfo[32..])
	data = []
	
	if bitsPerPixel <= 8:
		//Need to read in a Colour Table
	else:
		paddingVal = 3*width
		blankBytes = paddingVal % 4
		if blankBytes != 0:
			blankBytes = 4 - blankBytes
		//Need to read in the data
		dataSize = height*width
		currWidth = 0
		for i in 0..dataSize:
			values=RGBA(Byte.toUnsignedInt(file.read(1)),Byte.toUnsignedInt(file.read(1)),Byte.toUnsignedInt(file.read(1)),0.0)
			//When we get here. There might need to be more padding.
			data = data+[values]
			currWidth = currWidth + 1
			if currWidth == width:
				file.read(blankBytes)
				currWidth = 0
			
	return Image.Image(width, height, data)

