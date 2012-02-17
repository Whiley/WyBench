package imagelib.bmp

import * from whiley.lang.*
import imagelib.core.RGBA
import * from whiley.io.File
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

