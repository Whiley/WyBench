package imagelib.gif

import * from whiley.lang.*
import imagelib.core.RGBA
import imagelib.core.Image
import BlockBuffer

define Encoder as {
	[[int]] dict,
	int clearCode,
	int EOICode
	}

Encoder makeEncoder(int codeWidth):
	clearCode = Math.pow(2, codeWidth)
	endOfInformation = clearCode + 1
	dict = []
	for i in 0 .. clearCode + 2:
		dict = dict + [[i]]
	return {
	dict: dict,
	clearCode: clearCode,
	EOICode: endOfInformation
	}
	
Encoder resetEncoder(Encoder e):
	return {
	dict: e.dict[0..(e.clearCode)+2],
	clearCode: e.clearCode,
	EOICode: e.EOICode
	}

Encoder addDictEntry(Encoder e, [int] entry):
	return {
		dict: e.dict + [entry],
		clearCode: e.clearCode,
		EOICode: e.EOICode
	}
int searchDict([int] val, Encoder e):
	startVal = 0
	//Little hack to exploit the dictionary.
	//All values between 0..clearCode + 2 are single int arrays
	//Therefore, if the size of the array is bigger than 1, you can skip those
	//Values. Should be a bit faster
	if |val| == 1:
		startVal = 0
	else:
		startVal = arrayMax(val)
	for i in startVal..|e.dict|:
		if val == e.dict[i]:
			return i
	return -1
	
public [byte] ::encode(Image img):
	data = []
	//--------------------------
	// MAGIC NUMBER. 'GIF89A'
	//--------------------------
	data = data + List.reverse(Int.toUnsignedBytes(0x474946383961))
	
	//--------------------------
	// LOGICAL SCREEN DESCRIPTOR
	//--------------------------
	data = data + padUnsignedInt(img.width, 2)
	data = data + padUnsignedInt(img.height, 2)
	//Write the packed byte
	packed = 10000000b //Always Include the Global Colour Table
	
	list, size = getColorTable(img.data)
	res = Int.toUnsignedByte(size-2) //Image Resolution
	res = res << 4 //Needs to be shifted to the correct position so it can be OR'd 
	packed = packed | res 
	packed = packed | Int.toUnsignedByte(size-1)
	data = data + [packed]
	data = data + [Int.toUnsignedByte(0)] // Background Colour Index
	data = data + [Int.toUnsignedByte(0)] // Pixel Aspect Ratio
	
	//--------------------------
	// GLOBAL COLOUR TABLE
	//--------------------------
	for item in list:
		data = data + [Int.toUnsignedByte(Math.round(item.red*255))]
		data = data + [Int.toUnsignedByte(Math.round(item.green*255))]
		data = data + [Int.toUnsignedByte(Math.round(item.blue*255))]
	
	//--------------------------
	// Image Descriptor
	//--------------------------
	data = data + List.reverse(Int.toUnsignedBytes(0x2C)) // Header
	data = data + padUnsignedInt(0,2) // Image Top
	data = data + padUnsignedInt(0,2) // Image Left
	data = data + padUnsignedInt(img.width,2) //Image Width (As this is only one frame. Just use the entire image)
	data = data + padUnsignedInt(img.height,2)
	data = data + padUnsignedInt(0,1) //Packed byte
	
	//--------------------------
	// Data Encoding
	//--------------------------
	codes = encodeGif(img.data, list, size)
	data = data + [Int.toUnsignedByte(size)] //Write the compression MinSize
	
	//--------------------------
	// LZW Writing
	// Image sub-blocks can be a max of 255 bytes long, including the length byte
	// Therefore, the bytes need to be broken up into chunks of 254 bytes
	//--------------------------
	while |codes| > 254:
		data = data + [Int.toUnsignedByte(254)]
		data = data + codes[0..254]
		codes = codes[254..]
	
	// Add the last remaining block
	data = data + [Int.toUnsignedByte(|codes|)]
	data = data + codes
	
	//--------------------------
	// Image Finalising. 
	//--------------------------
	data = data + padUnsignedInt(0, 1) //No More Data left
	data = data + List.reverse(Int.toUnsignedBytes(0x3B)) //Trailer Byte
	
	return data
	
	
[byte] padUnsignedInt(int i, int padLength):
	data = Int.toUnsignedBytes(i)
	for j in |data|..padLength:
		data = data + [00000000b]
	return data
	
//--------------------------
// Gif Encode Routine
// @param array - List of RGBA values from the Image
// @param lookup - A dictionary of the RGBA values that exist in the image 
// This allows us to turn the RGBA array into a lookup code array
// @param codeWidth - Minimum LZW code word size
//--------------------------
[byte] ::encodeGif([RGBA] array, [RGBA] lookup, int codeWidth):
	codes = [] //Codes holds the list of table values
	//Convert RGBA array into index Array
	for rgb in array:
		codes = codes + [indexOf(lookup, rgb)]
	
	//--------------------------
	// Encode Variables
	//--------------------------
	encoder = makeEncoder(codeWidth)
	//clearCode = Math.pow(2, codeWidth) // Clear Code - The code that tells a decoder to reset the dictionary
	codeSize = codeWidth + 1
	currentMaxSize = Math.pow(2, codeWidth)
	written = 1
	writer = BlockBuffer.Writer()
	writer = compressInt(writer, encoder.clearCode, codeSize)
	
	indexBuffer = []
	iK = [] //This stores the Index Buffer + k value. Saves recomputing multiple times
	for i in 0..|codes|:
		k = codes[i]
		iK = indexBuffer + [k]
		
		if searchDict(iK, encoder) != -1:
			//Means this exists in the Dictionary. Therefore, append it to the buffer, and continue
			indexBuffer = iK
		else:
			encoder = addDictEntry(encoder, iK)
			writer = compressInt(writer, searchDict(indexBuffer, encoder), codeSize)
			written = written + 1
			indexBuffer = [k]
			
			if written == currentMaxSize:
				//The Dictionary is too full. Need to increase bit length
				written = 0
				if codeSize == 12:
					//Max width of LZW Reached. need to reset the dictionary
					// and Codewidth
					writer = compressInt(writer, encoder.clearCode, codeSize)
					codeSize = codeWidth +1
					indexBuffer = [] // Reset the Index Buffer
					written = 1
					encoder = resetEncoder(encoder)
				else:
					codeSize = codeSize + 1
				currentMaxSize = Math.pow(2, codeSize-1)
	writer = compressInt(writer, searchDict(indexBuffer, encoder), codeSize)
	writer = compressInt(writer, encoder.EOICode, codeSize)
	
	return writer.data


//--------------------------
// Gif Encode Routine
// @param writer - The Writer to write the bits to
// @param value - The integer to writer
// @param width - The width (in bits) that the integer written
// @Example - Writing 2 with a width of 5 would write out 00010b
//--------------------------

BlockBuffer.Writer ::compressInt(BlockBuffer.Writer write, int value, int width):
	
	bytes = Int.toUnsignedBytes(value)
	if width > 8 && |bytes| == 1:
		//The Writer requires >8 bits to be read, but the top values are all zero.
		//This just pads out the byte array so the writer can process the small value
		bytes = bytes + [00000000b] 
	
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
			currentByte = bytes[1]
			pos = 0
	return write

int indexOf([any] array, any element):
	for i in 0..|array|:
		if(array[i] == element):
			return i
	return -1

	
int arrayMax([int] array):
	max = 0
	for element in array:
		max = Math.max(max, element)
	return max
([RGBA], int) getColorTable([RGBA] array):
	table = {}
	for i in 0..|array|:
		table = table + {array[i]}
	tableArray = []
	for element in table:
		tableArray = tableArray + [element]
	
	loop = 1
	while Math.pow(2, loop) < |table|:
		loop = loop + 1
	
	for i in |table|..Math.pow(2, loop):
		tableArray = tableArray + [RGBA.RGBA(0.0, 0.0, 0.0, 1.0)]
	
	return tableArray, loop
