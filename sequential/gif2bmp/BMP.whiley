import * from whiley.lang.*
import * from whiley.io.File
import RGB from Color
import Image

public void ::write(Image img, string filename):
	debug "Writing BMP File: " + filename + "\n"
	writer = File.Writer(filename)
	//Write out Magic Header
	writer.write([01000010b, 01001101b])
	debug "Height: " + img.height + "\n"
	debug "Width: " + img.width + "\n"
	paddingVal = 3*img.width
	debug "Padding Value: " + paddingVal + "\n"
	blankBytes = paddingVal % 4
	if blankBytes != 0:
		blankBytes = 4 - blankBytes
	debug "Blank Bytes: " + blankBytes + "\n" 	
	debug "Padded up to: " + (paddingVal + blankBytes) + "\n"
	size = 54 + 3*(img.height * img.width) + (blankBytes * img.height)
	debug "WRITING SIZE: " + size + "\n"
	writer.write(Util.padUnsignedInt(size,4))
	writer.write(Util.padUnsignedInt(0, 4))
	writer.write(Util.padUnsignedInt(54, 4))

	//Finished Writing Data Header. Writing Info Header
	writer.write(Util.padUnsignedInt(40, 4)) // Header Size
	writer.write(Util.padUnsignedInt(img.width, 4)) //Width	
	writer.write(Util.padUnsignedInt(img.height, 4)) //Height
	writer.write(Util.padUnsignedInt(1, 2)) //Color Planes (MUST BE ONE)

	writer.write(Util.padUnsignedInt(24, 2)) // Bit Depth
	writer.write(Util.padUnsignedInt(0, 4)) // Compression Value
	writer.write(Util.padUnsignedInt(size - 54, 4)) // Size of raw Bitmap Data
	writer.write(Util.padUnsignedInt(2834, 4)) // Horizontal Resolution
	writer.write(Util.padUnsignedInt(2834, 4))	// Vertical Resolution
	writer.write(Util.padUnsignedInt(0, 4))
	writer.write(Util.padUnsignedInt(0, 4))
	debug "Size of Data: " + |img.data| + "\n"
	currWidth = 0
	for col in img.data:
		writer.write([Int.toUnsignedByte(col.b)])
		writer.write([Int.toUnsignedByte(col.g)])
		writer.write([Int.toUnsignedByte(col.r)])
		currWidth = currWidth + 1
		if currWidth == img.width:
			currWidth = 0
			if blankBytes != 0:
				writer.write(Util.padUnsignedInt(0, blankBytes))
	writer.close()

public int getBitDepth(Image img, [int] potential):
    numColors = getDistinctColors(img)
    debug "Number of Distinct Colours: " + numColors + "\n"
    for i in potential:
        if Math.pow(2, i) >= numColors:
            return i
    return -1

int getDistinctColors(Image img):
    table = {}
    for col in img.data:
        table = table + {col}
    return |table|

public [[RGB]] ::readBMP(Reader file):
	debug "Reading Bitmap File\n"
	BMPSize = Byte.toUnsignedInt(file.read(4))
	//debug "BMP File Size: " + BMPSize + "\n"
	reservedBlockA = file.read(2)
	reservedBlockB = file.read(2)
	pixelArrayOffset = Byte.toUnsignedInt(file.read(4))
	//debug "Pixel Array offset: " + pixelArrayOffset + "\n"
	
	//Reading the Information Header
	//This Contains Size, resolution, bpp, compression and color information
	headerSize = Byte.toUnsignedInt(file.read(4))
	debug "Reading Header Size: " + headerSize + "\n"
	assert headerSize == 40
	DIBInfo = file.read(36) // Read the rest of the 40 byte header, minus the information already read
	bitmapWidth = Byte.toInt(DIBInfo[0..3])
	bitmapHeight = Byte.toInt(DIBInfo[4..7])
	colorPlanes = Byte.toUnsignedInt(DIBInfo[8..9])
	bitsPerPixel = Byte.toUnsignedInt(DIBInfo[10..11])
	compressionMethod = Byte.toUnsignedInt(DIBInfo[12..15])
	imageSize = Byte.toUnsignedInt(DIBInfo[16..19])
	horizResolution =  Byte.toInt(DIBInfo[20..23])
	verticalResolution = Byte.toInt(DIBInfo[24..27])
	numColors = Byte.toUnsignedInt(DIBInfo[28..31])
	importantColors = Byte.toUnsignedInt(DIBInfo[32..])
	//debug "Bitmap Width: " + bitmapWidth + "\n"
	//debug "Bitmap Height: " + bitmapHeight + "\n"
	//debug "Colour Planes: " + colorPlanes + "\n"
	//debug "Bits Per Pixel: " + bitsPerPixel + "\n"
	//debug "Compression Method: " + compressionMethod + "\n"
	//debug "imageSize: " + imageSize + "\n"
	////debug "Horizontal Res: " + horizResolution + "\n"
	//debug "Vertical Res: " + verticalResolution + "\n"
	//debug "Number of Colours: " + numColors + "\n"
	//debug "Important Colours: " + importantColors + "\n" */
	dArray = []
	
	if bitsPerPixel <= 8:
		//Need to read in a Colour Table
	else:
		paddingVal = 3*bitmapWidth
		width = 4
		//while width < paddingVal:
		//	width = width *2 
		blankBytes = paddingVal % 4
		if blankBytes != 0:
			blankBytes = 4 - blankBytes
		debug "Padding Val: " + paddingVal + "\n"
		debug "Blank Bytes: " + blankBytes + "\n"
		widthArray = []
		for i in 0..bitmapHeight:
			for j in 0..bitmapWidth:
				values={r:Byte.toUnsignedInt(file.read(1)),g:Byte.toUnsignedInt(file.read(1)), b:Byte.toUnsignedInt(file.read(1))}
				widthArray = widthArray + [values]
			//When we get here. There might need to be more padding.
			//debug "Width Array: " + widthArray + "\n"
			dArray = dArray+[widthArray]
			widthArray = []
			file.read(blankBytes)
			
	return dArray

