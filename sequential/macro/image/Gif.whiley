import whiley.lang.*
import * from BitBuffer
import * from whiley.io.File
import RGB from Util

define GIFFile as {
	string|null header,
	screenDescriptor LSD,
	[RGB] colourTable,
	[Frame] frames
}


define screenDescriptor as {
	int width,
	int height, 
	bool GCT, //If a global Colour Table Exists
	int resolution, 
	bool sort,
	int GCTSize,
	int bgIndex,
	int aspectRatio
}

define Frame as {
	imageDescriptor|null ID,
	controlExtension|null GCE,
	int LZWMin,
	[imageSubblock] data
}

define controlExtension as {
	int disposal,
	bool input,
	bool transFlag,
	int delayTime,
	RGB transparentColor
}


define imageDescriptor as {
	int imageLeft,
	int imageTop,
	int imageWidth,
	int imageHeight,
	bool LCTFlag, //Defines whether a local colour table exists
	bool interlace, //Defines if the image is interlaced
	bool sort, // If the LCT is sorted
	int LCTSize //Size of the LCT (If Defined)
} 


define imageSubblock as {int length, [byte] data}

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

(screenDescriptor, Reader) ::getDescriptor(Reader file):
	iWidth = Byte.toUnsignedInt(file.read(2))
	iHeight = Byte.toUnsignedInt(file.read(2))
	packed = file.read(1)[0]
	global = false //Whether a Global Colour Table Exists
	if (packed & 10000000b) == 10000000b:
		global = true
	packed = packed << 1
	packed, resolution = Util.toUnsignedInt(packed, 3)
	resolution = resolution + 1
	sortflag = false
	if (packed & 10000000b) == 10000000b:
		sortflag = true
	packed = packed << 1
	packed, tableSize = Util.toUnsignedInt(packed,3)
	backgroundIndex = Byte.toUnsignedInt(file.read(1)) // Reads in the background is no Color is specified 
	aspectRatio = Byte.toUnsignedInt(file.read(1))
	
	return ({width: iWidth, height:iHeight, GCT: global, resolution: resolution, sort: sortflag, GCTSize: tableSize, bgIndex: backgroundIndex, aspectRatio: aspectRatio}, file)


(imageDescriptor, Reader) ::parseImageDescriptor(Reader file):
	left = Byte.toUnsignedInt(file.read(2))
	top = Byte.toUnsignedInt(file.read(2))
	width = Byte.toUnsignedInt(file.read(2))
	height = Byte.toUnsignedInt(file.read(2))
	byt = file.read(1)[0]
	colorTable = false
	if (byt & 10000000b) == 10000000b:
		colorTable = true
	interlace = false
	if (byt & 01000000b) == 01000000b:
		interlace = true
	sort = false
	if (byt & 00100000b) == 00100000b:
		sort = true
	byt = byt << 5
	byt, size = Util.toUnsignedInt(byt, 3)
	return ({imageLeft:left, imageTop:top, imageWidth:width, imageHeight:height, LCTFlag:colorTable, interlace:interlace, sort:sort, LCTSize:size}, file)
	
	
(imageSubblock, Reader) ::parseSubblock(Reader file, int length):
	data = file.read(length)
	return ({length:length, data:data}, file)
	
	
[Frame] ::parseFrames(Reader file):
	frames = []
	
	leadByte = file.read(1)[0]
	while leadByte != 00111011b:
		GCE = null
		imageDescriptor = null
		
		while leadByte == 00100001b || leadByte == 00101100b:
			if(leadByte == 00100001b):
				//GCE
				size = file.read(2)[1]
				file.read(Byte.toUnsignedInt(size)+1)
			else if(leadByte == 00101100b):
				//IMAGE DESCRIPTOR
				imageDescriptor, file = parseImageDescriptor(file)
			leadByte = file.read(1)[0]
		
		//WHEN WE GET HERE. THE IMAGE DATA FOLLOWS
		minSize = Byte.toUnsignedInt(leadByte)
		
		leadByte = Byte.toUnsignedInt(file.read(1)[0])
		blocks = []
		while leadByte != 0:
			imageBlock, file = parseSubblock(file, leadByte)
			blocks = blocks + [imageBlock]	
			leadByte = Byte.toUnsignedInt(file.read(1)[0])
		
		//Add New Frame
		cFrame = {GCE:GCE, ID:imageDescriptor, LZWMin:minSize, data:blocks}
		frames = frames + [cFrame]
		leadByte = file.read(1)[0]
	
	
	return frames
	
	
public [[int]] decodeFrame(Frame f, int width):
	codes = []
	nullCode = -1
	data_size = f.LZWMin
	array = []
	for arr in f.data:
		array = array + arr.data
	clear = Math.pow(2, data_size) // Dict already Contains the clear codes.
	end_of_information = clear + 1
	available = clear + 2
	code_size = data_size + 1
	code_mask = Byte.toUnsignedInt(Int.toUnsignedByte(1) << 1) - 1
	suffix = []
	prefix = []
	for i in 0..clear:
		suffix = suffix  + [Int.toUnsignedByte(i)]
		prefix = prefix + [0]
	length = |array|*8
	readBits = code_size
	read = BitBuffer.Reader(array, 0)
	val, read = BitBuffer.readUnsignedInt(read, code_size)
	count = 0
	first = 0
	top = 0
	pi = 0
	bi = 0
	old_code = val
	ch = val
	pixelStack = []
	available = Math.pow(2, code_size) -1
	debug "Available: " + available + "\n"
	dict = generateIntDict(data_size)
	values = []
	while readBits+code_size < length:
		code, read = BitBuffer.readUnsignedInt(read, code_size)
		debug "Code: " + code + " CodeSize: " + code_size + "\n"
		codes = codes + [code]
		readBits = readBits + code_size
		// Interpret the code
		
		if(code == end_of_information):
			break
		else if(code == clear):
			dict = generateIntDict(data_size)
			old_code = code
			code_size = data_size + 1
		else:
			str = ""
			if code >= |dict|:
				str = str + old_code
				str = str + ' ' + ch
			else:
				str = dict[code]
			for cha in str:
				if cha != ' ':
					//Dont Print out the Spaces.
					values = values + [Util.charToInt(cha)]
			ch = Util.stringSplit(str, ' ')[0]
			
			tempStr = ""
			tempStr = tempStr + old_code + ' ' + ch
			dict = dict + [tempStr]
			old_code = dict[code]
			
			// debug "Dict Size: " + |dict| + " Avail: " + available + "\n"
			if |dict|-1 > available:
				// Dict is 'full'
				// Increase Code size
				if code_size == 12:
					code_size = data_size + 1
				else:
					code_size = code_size + 1
				available = Math.pow(2, code_size) -1
			
			
	return generateTable(values, data_size, width)

[string] generateIntDict(int codeWidth):
	list = []
	i = 0
	while i < Util.intPower(2, codeWidth)+2:
		list = list + [""+i]
		i = i+1
	
	return list	
	
public [[RGB]] ::readGif(Reader file):
	LSD, file = getDescriptor(file)
	colourTable = buildColourTable(file, LSD.GCTSize)
	frames = parseFrames(file)
	frame = frames[0]
	file.close()
	//codeList = computeLZWDecode(byteList, LZWminSize, dSize, dict, width)
	//dArray = generateTable(codeList, LZWminSize, width)
	val = decodeFrame(frame, LSD.width)
	return codeToRGB(val, colourTable)

[[int]] generateTable([int] codes, int bitSize, int width):
	dict = generateIntDict(bitSize)
	values = []
	dictSize = Util.intPower(2, bitSize)
	debug "Dict Generation. bitSize: " + bitSize + " Generated Size: " + |dict| + " DictS: " + dictSize +"\n"
	clearCode = dictSize + ""
	endCode = (dictSize + 1) + ""
	oldCode = dict[codes[0]]
	debug "Clear Code: " + clearCode + " End Code: " + endCode + " OldCode: " + oldCode + "\n"
	ch = oldCode
	debug "Dict Size: " + |dict| + "\n"
	for val in 1..|codes|-1:
		str = ""
		debug "Current Code: " +  codes[val] + "\n"
		if oldCode == clearCode:
			debug "Clear Code Found: \n"
			dict = generateIntDict(bitSize)
			oldCode = dict[codes[val]]
			values = values +[Util.charToInt(oldCode)]
			ch = oldCode
			val = val + 1
		else:
			debug "Search: " + codes[val] + "      " + (oldCode+ ' ' + codes[val]) +"\n"
			
			debug "In Array: " + Util.contains(dict, (oldCode+ ' ' + codes[val])) + "\n"
			if codes[val] >= |dict|:
			//if Util.contains(dict, (oldCode+ ' ' + codes[val])):
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
			debug "Adding to Dict: (" + codes[val] + ")" + (oldCode+ ' ' +ch) + " CURRENT DICT SIZE:  " + |dict| + "\n"
			oldCode = dict[codes[val]]
			
	value = |values|/width
	dArray = []
	for i in 0..value:
		dArray = dArray + [values[(i*width)..((i+1)*width)]]
	return dArray


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