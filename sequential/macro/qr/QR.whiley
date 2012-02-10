import * from whiley.lang.*
import * from whiley.io.File
import RGB from Util

public [[bool]] ::parseImage(string filename):
	file = File.Reader(filename)
	header = String.fromASCII(file.read(2))
	if header != "BM":
		//File Format Not Supported
		debug "File Format Not Supported. Only BMP at this stage\n"
	
	//Can Read Format
	rgbArray = BMP.readBMP(file)
	boolArray = RGBtoBW(rgbArray) // This converts the Image from RGB to Boolean B/W Codes
	//normArray = normaliseBW(boolArray) // This normalises the size of the array. Scales everything down to 1x1. Used for image scanning/Recognition
	return normaliseBW(boolArray)

	

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