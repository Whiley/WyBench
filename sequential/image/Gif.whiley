import * from whiley.lang.*
import * from BitBuffer
import * from whiley.io.File
import RGB from Util

public void ::writeGif([[RGB]] array, string filename):
	writer = File.Writer(filename)
	//Write the Header Block
	header = List.reverse(Int.toUnsignedBytes(0x474946383961))
	writer.write(header)
	
	//Write the Logical Screen Descriptor
	writer.write(Util.padUnsignedInt(|array|, 2)) // Width
	writer.write(Util.padUnsignedInt(|array[0]|, 2)) // Height
	packedByte = 10000000b // Always Include Global Colour Table
	packedByte = packedByte | 00010000b // Color Resolution
	list, listSize = getColorTable(array)
	packedByte = packedByte | Int.toUnsignedByte(listSize)
	writer.write([packedByte])
	writer.write(Util.padUnsignedInt(0, 2))
	//writer.write(Util.padUnsignedInt(0, 2))
	
	//Write the Global Color Table
	lookupTable = []
	for item in list:
		writer.write([Int.toUnsignedByte(item.r)])
		writer.write([Int.toUnsignedByte(item.g)])
		writer.write([Int.toUnsignedByte(item.b)])
		lookupTable = lookupTable + [item]
	debug "Lookup Table Size: " + lookupTable + "\n"
	//Now need to write the Image Descriptor
	writer.write(List.reverse(Int.toUnsignedBytes(0x2C))) //Block Header
	writer.write(Util.padUnsignedInt(0,2)) //Image Top
	writer.write(Util.padUnsignedInt(0,2)) //Image Left
	writer.write(Util.padSignedInt(|array|,2))
	writer.write(Util.padSignedInt(|array[0]|,2))
	writer.write(Util.padSignedInt(0, 1))
	
	codes = encodeLZW(array, lookupTable, listSize)
	//codes = List.reverse(codes)
	compressedCodes = compressCodes(codes, listSize)
	writer.write(Util.padUnsignedInt(2, 1))
	writer.write(Util.padUnsignedInt(|compressedCodes|, 1))
	writer.write(compressedCodes)
	writer.write(Util.padUnsignedInt(0, 1))
	writer.write(List.reverse(Int.toUnsignedBytes(0x3B))) // Trailer Byte
	writer.close()

public [[RGB]] ::readGif(Reader file):
	//When we're here, the only thing read is the magic number
	width = Byte.toUnsignedInt(file.read(2))
	height = Byte.toUnsignedInt(file.read(2))
	packed = file.read(1)[0]
	global = 0 //Whether a Global Colour Table Exists
	if (packed & 10000000b) == 10000000b:
		global = 1
	packed = packed << 1
	packed, resolution = Util.toUnsignedInt(packed, 3)
	resolution = resolution + 1
	sortflag = 0
	if (packed & 10000000b) == 10000000b:
		sortflag = 1
	packed = packed << 1
	packed, tableSize = Util.toUnsignedInt(packed,3)
	
	debug "Width: " + width + "\n"
	debug "Height: " + height + "\n"
	debug "Global Table: " + global + "\n"
	debug "Res Depth: " + resolution + "\n"
	debug "Sort Flag: " + sortflag + "\n"
	debug "Table Size N: " + tableSize + "\n"
	
	backgroundIndex = Byte.toUnsignedInt(file.read(1)) // Reads in the background is no Color is specified 
	aspectRatio = Byte.toUnsignedInt(file.read(1))
	colourTable = buildColourTable(file, tableSize)
	debug  "Colour Table Built" + "\n"
	leadByte = file.read(1)[0]
	
	// Parses the Image Descriptor and Graphical Control Extensions (Used for Transparency and Animation)
	while leadByte == 00100001b || leadByte == 00101100b:
		if(leadByte == 00100001b):
			size = file.read(2)[1]
			file.read(Byte.toUnsignedInt(size)+1)
		else if(leadByte == 00101100b):
			file.read(9) //FIXME: Deal with this Correctly
		leadByte = file.read(1)[0]
		
	//When we get here. The byte currently stored in leadByte is the first of the image data
	LZWminSize = Byte.toUnsignedInt(leadByte) //Minimum Compression code size. Used to decode compressed output codes.
	debug  "Min LZW Size: " + LZWminSize + "\n"
	
	leadByte = Byte.toUnsignedInt(file.read(1)[0])
	dArray = []
	dict = generateIntDict(LZWminSize)
	while leadByte != 0:
		debug  "Bytes to Read: " + leadByte + "\n"
		subBlock = file.read(leadByte)
		dArray, dict = decodeLZW(subBlock, LZWminSize, leadByte, dict, width)
		leadByte = Byte.toUnsignedInt(file.read(1)[0])
	//When we get here, there is no data left to read in the block
	debug "" + dArray + "\n"
	file.close()
	return codeToRGB(dArray, colourTable)

[byte] encodeLZW([[RGB]] array, [RGB] table, int bitWidth):
	//Need to Convert Array to Table
	codes = []
	for i in 0..|array|:
		for j in 0..|array[0]|:
			codes = codes + [Util.indexOf(table, array[i][j])]
	dict = generateIntDict(bitWidth+1)
	initDict = |dict|
	output = [Int.toUnsignedByte(initDict-2)] // Leading Clear Code
	currentString = ""
	for ch in codes:
		temp = currentString + ' ' +  ch
		temp = Util.stringTrim(temp)
		if temp in dict:
			currentString = currentString + ' ' + ch
		else:
			currentString = Util.stringTrim(currentString)
			output = output + [Int.toUnsignedByte(Util.indexOf(dict, currentString))]
			dict = dict + [temp]
			currentString = "" + ch
	
	
	
	output = output + [Int.toUnsignedByte(Util.indexOf(dict, currentString))]
	output = output + [Int.toUnsignedByte(initDict-1)]
	return output


[[RGB]] codeToRGB([[int]] dArray, [RGB] colourTable):
	finalArray = []
	for array in dArray:
		innerArr = []
		for i in array:
			innerArr = innerArr + [colourTable[i]]
		finalArray = finalArray+[innerArr]
		innerArr = []
	return finalArray

[RGB] ::buildColourTable(Reader file, int tableSize):
	colorsToRead = Util.intPower(2, tableSize+1)
	colourTable = []
	for i in 0..colorsToRead:
		red = Byte.toUnsignedInt(file.read(1))
		green = Byte.toUnsignedInt(file.read(1))
		blue = Byte.toUnsignedInt(file.read(1))
		rgb = {r: red, g: green, b:blue}
		colourTable = colourTable + [rgb]
	return colourTable

({RGB}, int) getColorTable([[RGB]] array):
	table = {}
	for i in 0..|array|:
		for j in 0..|array[0]|:
			rgb = array[i][j]
			table = table + {rgb}
	
	table = table + {{r:0, g:0, b:0}}
	//Figure out the size of the table to be written out.
	init = 1
	while Util.intPower(2, init+1) < |table|:
		init = init + 1
	debug "Table Size: " + |table| + "\n"
	return table, init

[string] generateIntDict(int codeWidth):
	list = []
	i = 0
	while i < Util.intPower(2, codeWidth)+2:
		list = list + [""+i]
		i = i+1
	
	return list

([[int]], [string]) ::decodeLZW([byte] bArray, int bitSize, int dataSize, [string] dict, int width):
	buff = BitBuffer.Reader(bArray, 0)
	codes = []
	bitReadSize = bitSize + 1
	readBits = 0
	loopTimes = 0
	maxLoop = Util.intPower(2, bitSize)
	maxBits = dataSize * 8
	while readBits < maxBits && readBits+bitReadSize < maxBits:
		if loopTimes >=maxLoop:
			loopTimes = 0
			maxLoop = Util.intPower(2,bitReadSize)
			bitReadSize = bitReadSize + 1
		(val, buff) = BitBuffer.readUnsignedInt(buff, bitReadSize)
		codes = codes +[val]
		readBits = readBits + bitReadSize
		loopTimes = loopTimes + 1
	values = []
	dictSize = Util.intPower(2, bitSize)
	clearCode = dictSize + ""
	endCode = (dictSize + 1) + ""
	oldCode = dict[codes[0]]
	ch = oldCode
	
	for val in 1..|codes|-1:
		str = ""
		if oldCode == clearCode:
			dict = generateIntDict(bitSize)
			oldCode = dict[codes[val]]
			values = values +[Util.charToInt(oldCode)]
			ch = oldCode
			val = val + 1
		else:
			if codes[val] >= |dict|:
				//Value is not in the dictionary
				str = oldCode
				str = str + ' ' +  ch
			else:
				str = dict[codes[val]]
			for cha in str:
				if cha != ' ':
					//Dont Print out the Spaces.
					values = values + [Util.charToInt(cha)]
			ch = Util.stringSplit(str, ' ')[0]
			dict = dict + [(oldCode+ ' ' +ch)]
			oldCode = dict[codes[val]]
			
	value = |values|/width
	dArray = []
	for i in 0..value:
		dArray = dArray + [values[(i*width)..((i+1)*width)]]
	return (dArray, dict)

[byte] compressCodes([byte] array, int bitsize):
	debug "Bitsize: " + bitsize + "\n"
	if bitsize < 3:
		bitsize = 3
	val = bitsize
	i = 0
	maxLoop = Util.intPower(2, val-1)
	writer = BitBuffer.Writer()
	for byt in array:
		writer = writeCompressedCodes(byt, val, writer)
		i = i + 1
		if i >= maxLoop:
			i = 0
			val = val + 1
			maxLoop = Util.intPower(2, val-1)
		
	
	return writer.data
	
BitBuffer.Writer writeCompressedCodes(byte b, int length, BitBuffer.Writer w):
	toWrite = Byte.toString(b)[(8-length)..] // Takes the last x bytes
	toWrite = Util.stringReverse(toWrite)
	toWrite = toWrite[1..] // parse the b off
	for c in toWrite:
		if c == '1':
			w = BitBuffer.write(w, true)
		else:
			w = BitBuffer.write(w, false)
	return w