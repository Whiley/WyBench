package imagelib.bmp

import * from whiley.lang.*
import imagelib.core.RGBA
import imagelib.core.Image

public [byte] encode(Image img):
	data = []
	//Append the Magic Header "BM"
	data = data + [01000010b, 01001101b]
	
	
	paddingVal = 3*img.width //This is the width of a row in bytes.
	//The total width of a row in the BMP format must be a multiple of Four. 
	blankBytes = paddingVal % 4
	if blankBytes != 0:
		blankBytes = 4 - blankBytes
	size = 54 + 3*(img.height * img.width) + (blankBytes * img.height)
	
	data = data + padUnsignedInt(size,4) //Total Size of the BMP file, including header information
	data = data + padUnsignedInt(0, 4) // Two reserved 2 byte blocks. The values can be used for whatever the creation software wants. Leave blank
	data = data + padUnsignedInt(54, 4) // Offset of the Pixel array (Always 54, 14 byte file header, 40 byte Information Header)

	//Finished Writing Data Header. Writing Info Header
	data = data + padUnsignedInt(40, 4) // Header Size
	data = data + padUnsignedInt(img.width, 4) //Width	
	data = data + padUnsignedInt(img.height, 4) //Height
	data = data + padUnsignedInt(1, 2) //Color Planes (MUST BE ONE)

	data = data + padUnsignedInt(24, 2) // Bit Depth
	data = data + padUnsignedInt(0, 4) // Compression Value
	data = data + padUnsignedInt(size - 54, 4) // Size of raw Bitmap Data
	data = data + padUnsignedInt(2834, 4) // Horizontal Resolution
	data = data + padUnsignedInt(2834, 4)	// Vertical Resolution
	data = data + padUnsignedInt(0, 4)
	data = data + padUnsignedInt(0, 4) //Important Colours used. This is generally ignored
	
	currWidth = 0
	
	for col in img.data:
		data = data + [Int.toUnsignedByte(Math.round(col.blue*255))]
		data = data + [Int.toUnsignedByte(Math.round(col.green*255))]
		data = data + [Int.toUnsignedByte(Math.round(col.red*255))]
		
		currWidth = currWidth + 1
		if currWidth == img.width:
			currWidth = 0
			if blankBytes != 0:
				data = data + padUnsignedInt(0, blankBytes)
			
	
	return data
	
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

