import * from whiley.lang.*
import * from whiley.io.File
import RGB from Util

define QR as { 
	int version, //(DONE) Version Number, Between 1 and 40 
	int numAligns, //(DONE)  Number of Extra aligment blocks. Does not include the 3 corner alignments
	int numModulesSide, //(DONE) Number of Modules. Equals to 17 + (Version *4)  	(Denoted as A)
	int funcModules, //Number of Functional Pattern Modules  			(Denoted as B)
	int FVIModules, // Format & Version Modules							(Denoted as C)
	int dataModules, //Calculated by (A^2-B-C)
	int dataCapacity, // Number of Available Codewords
	int remainderBits, // Number of Bits left
	[int] markerCentres, //List of alignment centers
	[[bool]] rawData //Binary Representation of the Data
	}

public QR ::parseImage(string filename):
	file = File.Reader(filename)
	header = String.fromASCII(file.read(2))
	if header != "BM":
		//File Format Not Supported
		debug "File Format Not Supported. Only BMP at this stage\n"
	
	//Can Read Format
	rgbArray = BMP.readBMP(file)
	boolArray = RGBtoBW(rgbArray) // This converts the Image from RGB to Boolean B/W Codes
	normArray = normaliseBW(boolArray) // This normalises the size of the array. Scales everything down to 1x1. Used for image scanning/Recognition
	
	return getQRfromArray(normArray)

//@param v - QR Version
int getFuncModules(int v):
	//Func can be calced in levels. There are multiple 'base' levels.
	//Each level above this, until another 'base' level is base + (actual-base)*8
	minV = 0
	baseMod = 0
	if v == 1:
		return 202
	else if v < 7:
		minV = 2
		baseMod = 235
	else if v < 14:
		minV = 7
		baseMod = 390
	else if v < 21:
		minV = 14
		baseMod = 611
	else if v < 28:
		minV = 21
		baseMod = 882
	else if v < 35:
		minV = 28
		baseMod = 1203
	else:
		minV = 35
		baseMod = 1574
	
	return baseMod + ((v-minV)*8)
	
	
QR getQRfromArray([[bool]] array):
	//Array is Normalised. Need to Calculate all other information
	width = |array| // A
	version = (width-17)/4
	numAligns = getAlignBlocks(version)
	funcPatternModules = getFuncModules(version)
	FIVMod = 0
	if version < 7:
		FIVMod = 31
	else:
		FIVMod = 67
	dataMod = (width*width) - funcPatternModules - FIVMod
	dataCapacity = dataMod / 8
	remainderBits = dataMod % 8
	alignmentCentres = getAlignmentCentres(version)
	
	return {version: version, numAligns: numAligns, numModulesSide:width, funcModules: funcPatternModules, FVIModules: FIVMod, dataModules: dataMod, dataCapacity: dataCapacity, remainderBits: remainderBits, markerCentres: alignmentCentres, rawData: array}

[int] getAlignmentCentres(int version):
	return [1]
	
void debugArray([any] array):
	for elem in array:
		debug "" + elem + "\n"

[[bool]] normaliseBW([[bool]] array):
	initArray = array[0]
	//debugArray(array)
	count = 0
	//Count the number of pixels that makes up a block
	for b in initArray:
		if b:
			//Terminate Here
			break
		else:
			count = count + 1
	debug "Count: " + count + ". Pixels Per Square(pps): " + count / 7 + "\n"
	pixWidth = count/7 //Divide by 7 because that is the bounding alignment box width(height too.)
	assert count % 7 == 0
	
	width = |array[0]|/pixWidth
	height = |array|/pixWidth
	ret = []
	currRow = []
	for i in 0..height:
		for j in 0..width:
			
			check = []
			
			for ij in i*pixWidth..(i*pixWidth)+pixWidth:
				check = check + [array[ij][j*pixWidth..(j*pixWidth)+pixWidth]]
			//This is just a sanity check that needs to pass. FIXME: Make this error
			if allElementsEqual(check):
				currRow = currRow + [check[0][0]]
			else:
				debug "ERROR. NOT EQUAL. SHOULD EXIT HERE\n"
		
		ret = ret + [currRow]
		currRow = []
	return ret

public void decodeData([[bool]] data):
	assert |data| == |data[0]|
	version = ((|data|-17)/4)
	alignBlocks = getAlignBlocks(version)
	
	
// 
// Returns the number of aligment blocks
//
int getAlignBlocks(int version):
	if version == 0:
		return 0
	else if version < 7:
		return 1
	else if version < 21:
		return 6
	else if version < 28:
		return 22
	else if version < 35:
		return 33
	else:
		return 46
	
bool allElementsEqual([[any]] array):
	element = array[0][0]
	for i in 0..|array|:
		for j in 0..|array[0]|:
			if array[i][j] != element:
				return false
	return true
	
[[bool]] RGBtoBW([[RGB]] array):
	ret = []
	currentRow = []
	for i in 0..|array|:
		for j in 0..|array[0]|:
			rgb = array[i][j]
			r = rgb.r
			g = rgb.g
			b = rgb.b
			
			if r == 0 && g == 0 && b == 0:
				currentRow = currentRow+[false]
			else if r == 255 && g == 255 && b == 255:
				currentRow = currentRow+[true]
			else:
				//ERROR DETECTED
				debug "ERROR DETECTED. INVALID COLOUR\n"
		ret = ret + [currentRow]
		
		currentRow = []
	return ret
	
