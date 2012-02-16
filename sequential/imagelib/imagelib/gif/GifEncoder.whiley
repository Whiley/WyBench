package imagelib.gif

import * from whiley.lang.*
import * from whiley.io.File
import imagelib.core.Image
import imagelib.core.RGBA

public void ::write(Image img, string filename):
	writer = File.Writer(filename)
	//Write the Header Block - 'GIF89a'
	writer.write(List.reverse(Int.toUnsignedBytes(0x474946383961)))
	writer.write(padUnsignedInt(img.width, 2))
	writer.write(padUnsignedInt(img.height, 2))
	//Write the packed byte
	packed = 10000000b //Always Include the Global Colour Table
	packed = packed | 00010000b // Resolution
	list, size = getColorTable(img.data)
	packed = packed | Int.toUnsignedByte(size)
	writer.write([packed])
	
	lookupTable = [] // To be used in the encoding process
	//Append the Global Colour Table
	for item in list:
		writer.write([Int.toUnsignedByte(Math.round(item.red*255))])
		writer.write([Int.toUnsignedByte(Math.round(item.green*255))])
		writer.write([Int.toUnsignedByte(Math.round(item.blue*255))])
		lookupTable = lookupTable + [item]
	debug "LOOKUP: " + lookupTable + "\n"
	//Write the Image Descriptor
	writer.write(List.reverse(Int.toUnsignedBytes(0x2C))) // Header
	writer.write(padUnsignedInt(0,2)) // Image Top
	writer.write(padUnsignedInt(0,2)) // Image Left
	writer.write(padUnsignedInt(img.width,2)) //Image Width (As this is only one frame. Just use the entire image)
	writer.write(padUnsignedInt(img.height,2))
	writer.write(padUnsignedInt(0,1)) //Packed byte
	
	//Time to Encode and compress the image data
	codes = encodeGif(img.data, lookupTable, size)
 
[byte] padUnsignedInt(int i, int padLength):
	data = Int.toUnsignedBytes(i)
	for j in |data|..padLength:
		data = data + [00000000b]
	return data

[byte] encodeGif([RGBA] array, [RGBA] lookup, int codeWidth):
	//Transform all of the RGB values into their respective
	//Table Values. Required to encode
	codes = [] //Codes holds the list of table values
	
	for rgb in array:
		codes = codes + [indexOf(lookup, rgb)]
	//Define Encoding Variables
	clearCode = Math.pow(2, codeWidth)
	endOfInformation = clearCode + 1
	codeSizeLimit = clearCode * 2
	codeSize = codeWidth + 1
	maximumSize = 4095 //This is a constant. If the dictionary is this size, then the dict needs to be reset, and a reset code appended
	//Dict is the Code Lookup Table
	dict = []
	for i in 0 .. clearCode + 2:
		dict = dict + [[i]]
	debug "" + dict + "\n"
	codeList = [] //Final List. Ready for output
	codeList = codeList + [clearCode] //First Code should always be the reset dict code
	indexBuffer = [codes[0]]
	iK = [] //This stores the Index Buffer + k value. Saves recomputing multiple times
	for i in 0..|codes|:
		iK = []
		k = codes[i]
		for elem in indexBuffer:
			iK = iK + [elem]
		iK = iK + [k]
		debug "Code: " + k + " Index Buffer: " + indexBuffer + " iK: " + iK + "\n"
		if indexOf(dict, iK) != -1:
			//Means this exists in the Dictionary. Therefore, append it to the buffer, and continue
			debug "Found: " + iK + " at Index: " + indexOf(dict, iK) + "\n"
			indexBuffer = indexBuffer + [k]
		else:
			dict = dict + [iK] 
			codeList = codeList + [indexOf(dict, indexBuffer)]
			indexBuffer = [k]
			debug "Dict: " + dict + "\n"
			if |dict| == maximumSize:
				//Need to Reset and then append a clearcode
				dict = []
				for j in 0 .. clearCode + 2:
					dict = dict + [[j]]
				codeList = codeList + [clearCode]
	codeList = codeList + [endOfInformation]
	debug "" + codeList + "\n"
	return []

int indexOf([any] array, any element):
	for i in 0..|array|:
		if(array[i] == element):
			return i
	return -1

({RGBA}, int) getColorTable([RGBA] array):
	table = {}
	for i in 0..|array|:
		rgb = array[i]
		table = table + {rgb}
	table = table + {RGBA(0,0,0,0)}
	//Figure out the size of the table to be written out.
	init = 1
	while Math.pow(2, init+1) < |table|:
		init = init + 1
	return table, init
