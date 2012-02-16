package imagelib.gif

import * from whiley.lang.*
import imagelib.core.RGBA
import imagelib.core.Image
import BlockBuffer

public [byte] ::encode(Image img):
	data = []
	currentSize = 0 //DEBUGGING ONLY
	//--------------------------
	// MAGIC NUMBER. 'GIF89A'
	//--------------------------
	data = data + List.reverse(Int.toUnsignedBytes(0x474946383961))
	currentSize = currentSize + 6
	debug "Data Size After Header: " + |data| + " Should be: " + currentSize + "\n"
	//--------------------------
	// LOGICAL SCREEN DESCRIPTOR
	//--------------------------
	data = data + padUnsignedInt(img.width, 2)
	data = data + padUnsignedInt(img.height, 2)
	//Write the packed byte
	packed = 10000000b //Always Include the Global Colour Table
	packed = packed | 00010000b // Resolution
	list, size = getColorTable(img.data)
	packed = packed | Int.toUnsignedByte(size-1)
	data = data + [packed]
	data = data + [Int.toUnsignedByte(0)] // Background Colour Index
	data = data + [Int.toUnsignedByte(0)] // Pixel Aspect Ratio
	currentSize = currentSize + 7
	debug "Data Size After Header: " + |data| + " Should be: " + currentSize + "\n"
	//--------------------------
	// GLOBAL COLOUR TABLE
	//--------------------------
	//lookupTable = [] // To be used in the encoding process
	for item in list:
		data = data + [Int.toUnsignedByte(Math.round(item.red*255))]
		data = data + [Int.toUnsignedByte(Math.round(item.green*255))]
		data = data + [Int.toUnsignedByte(Math.round(item.blue*255))]
		//lookupTable = lookupTable + [item]
	currentSize = currentSize + (3*|list|)
	debug "Data Size After Colour Table: " + |data| + " Should be: " + currentSize + "\n"
	
	//--------------------------
	// Image Descriptor
	//--------------------------
	data = data + List.reverse(Int.toUnsignedBytes(0x2C)) // Header
	data = data + padUnsignedInt(0,2) // Image Top
	data = data + padUnsignedInt(0,2) // Image Left
	data = data + padUnsignedInt(img.width,2) //Image Width (As this is only one frame. Just use the entire image)
	data = data + padUnsignedInt(img.height,2)
	data = data + padUnsignedInt(0,1) //Packed byte
	currentSize = currentSize + 10
	debug "Data Size After Image Descriptor: " + |data| + " Should be: " + currentSize + "\n"
	//Time to Encode and compress the image data
	codes = encodeGif(img.data, list, size)
	debug "Size: " + size + "\n"
	data = data + [Int.toUnsignedByte(size)]
	currentSize = currentSize + 1
	debug "Data Size After Adding Lead MinSize: " + |data| + " Should be: " + currentSize + "\n"
	while |codes| > 254:
		data = data + [Int.toUnsignedByte(254)]
		
		data = data + codes[0..254]
		codes = codes[254..]
	data = data + [Int.toUnsignedByte(|codes|)]
	
	debug "Adding Last Codes of Length: " + |codes| + "\n"
	data = data + codes
	debug "Size of all data: " + |data| + "\n"
	data = data + padUnsignedInt(0, 1) //No More Data left
	data = data + List.reverse(Int.toUnsignedBytes(0x3B)) 
	return data

[byte] padUnsignedInt(int i, int padLength):
	data = Int.toUnsignedBytes(i)
	for j in |data|..padLength:
		data = data + [00000000b]
	return data

[byte] ::encodeGif([RGBA] array, [RGBA] lookup, int codeWidth):
	codes = [] //Codes holds the list of table values
	for rgb in array:
		codes = codes + [indexOf(lookup, rgb)]
		
	//Define Encoding Variables
	clearCode = Math.pow(2, codeWidth)
	debug "CodeWidth: " + codeWidth + "\n"
	debug "Clear Code: " + clearCode + "\n"
	endOfInformation = clearCode + 1
	codeSizeLimit = clearCode * 2
	codeSize = codeWidth + 1
	maximumSize = 4095 //This is a constant. If the dictionary is this size, then the dict needs to be reset, and a reset code appended
	currentMaxSize = Math.pow(2, codeWidth)
	written = 0
	//Dict is the Code Lookup Table
	writer = BlockBuffer.Writer()
	dict = []
	for i in 0 .. clearCode + 2:
		dict = dict + [[i]]
	
	writer = compressInt(writer, clearCode, codeSize)
	written =1 
	indexBuffer = []
	iK = [] //This stores the Index Buffer + k value. Saves recomputing multiple times
	for i in 0..|codes|:
		iK = []
		k = codes[i]
		for elem in indexBuffer:
			iK = iK + [elem]
		iK = iK + [k]
		//debug "Code: " + k + " Index Buffer: " + indexBuffer + " iK: " + iK + "\n"
		if indexOf(dict, iK) != -1:
			//Means this exists in the Dictionary. Therefore, append it to the buffer, and continue
			//debug "Found: " + iK + " at Index: " + indexOf(dict, iK) + "\n"
			indexBuffer = indexBuffer + [k]
		else:
			dict = dict + [iK]
			vToWrite = indexOf(dict, indexBuffer)
			writer = compressInt(writer, vToWrite, codeSize)
			written = written + 1
			indexBuffer = [k]
			//debug "Written: " + written + " Max: " + currentMaxSize + "\n"
			if written == currentMaxSize:
				//The Dictionary is too full. Need to increase bit length
				written = 0
				if codeSize == 12:
					//Hit max width
					writer = compressInt(writer, clearCode, codeSize)
					codeSize = codeWidth +1
					dict = []
					for j in 0 .. clearCode + 2:
						dict = dict + [[j]]
					
				else:
					codeSize = codeSize + 1
				currentMaxSize = Math.pow(2, codeSize-1)
	writer = compressInt(writer, indexOf(dict, indexBuffer), codeSize)
	writer = compressInt(writer, endOfInformation, codeSize)
	
	return writer.data

BlockBuffer.Writer ::compressInt(BlockBuffer.Writer write, int value, int width):
	
	bytes = Int.toUnsignedBytes(value)
	if width > 8 && |bytes| == 1:
		//The Writer requires >8 bits to be read, but the top values are all zero.
		//This just pads out the byte array so the writer can process the small value
		bytes = bytes + [00000000b] 
	//debug "Writing Int: " + value + " Width: " + width +  " Bytes: " + bytes + "\n"
	pos = 0 //The position in the current Byte. If this becomes > 8, read the other byte
	currentByte = bytes[0]
	for i in 0..width:
		if currentByte & 00000001b == 00000001b: 
			//The top bit is 1, therefore, true
			write = BlockBuffer.write(write, true)
		else:
			write = BlockBuffer.write(write, false)
		currentByte = currentByte >> 1 
		
		pos = pos + 1
		if pos == 8 && width > 8:
			//debug "Bytes: " + bytes + "\n"
			currentByte = bytes[1]
			pos = 0
	//debug "" +  write.data + "\n"
	return write

int indexOf([any] array, any element):
	for i in 0..|array|:
		if(array[i] == element):
			return i
	return -1

([RGBA], int) getColorTable([RGBA] array):
	table = {}
	for i in 0..|array|:
		table = table + {array[i]}
	
	tableArray = []
	for element in table:
		tableArray = tableArray + [element]
	
	loop = 1
	while Math.pow(2, loop) < |table|:
		//debug "MathPower: " + Math.pow(2, init) + " Init: " + init + " Table Size: " + |table| + "\n"
		loop = loop + 1
	
	for i in |table|..Math.pow(2, loop):
		tableArray = tableArray + [RGBA.RGBA(0.0, 0.0, 0.0, 1.0)]
	
	return tableArray, loop
