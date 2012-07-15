import * from whiley.lang.*
import * from whiley.io.File
import RGB from Util

public [[RGB]] ::readBMP(Reader file):
	BMPSize = Byte.toUnsignedInt(file.read(4))
	reservedBlockA = file.read(2)
	reservedBlockB = file.read(2)
	pixelArrayOffset = Byte.toUnsignedInt(file.read(4))
	
	//Reading the Information Header
	//This Contains Size, resolution, bpp, compression and color information
	headerSize = Byte.toUnsignedInt(file.read(4))
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
	dArray = []
	
	if bitsPerPixel <= 8:
		//Need to read in a Colour Table
	else:
		paddingVal = 3*bitmapWidth
		width = 4
		blankBytes = paddingVal % 4
		if blankBytes != 0:
			blankBytes = 4 - blankBytes
		widthArray = []
		for i in 0..bitmapHeight:
			for j in 0..bitmapWidth:
				values={r:Byte.toUnsignedInt(file.read(1)),g:Byte.toUnsignedInt(file.read(1)), b:Byte.toUnsignedInt(file.read(1))}
				widthArray = widthArray + [values]
			//When we get here. There might need to be more padding.
			dArray = dArray+[widthArray]
			widthArray = []
			file.read(blankBytes)
			
	return dArray

