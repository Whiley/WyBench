import * from whiley.lang.*
import * from whiley.io.File
import * from whiley.lang.Errors
import RGB from Color

define gifDescriptor as "GIF89a"

[string] stringSplit(string str, char split):
	strArray = []
	currStr = ""
	for ch in str:
		if ch == split:
			strArray = strArray + [currStr]
			currStr = ""
		else:
			currStr = currStr + ch
	strArray = strArray + [currStr]
	return strArray

[[RGB]]|null ::processInputFile(string fName):
	file = File.Reader(fName)
	bytes = file.read(1)
	if(bytes == [10001001b]):
		debug "READING PNG FILE: \n"
		return PNG.readPNG(file)
	s = String.fromASCII(bytes + file.read(1)) // Header Block - To account for BMP
	if s == "BM":
		return BMP.readBMP(file)
	s = s + String.fromASCII(file.read(4))
	if s == gifDescriptor || s == "GIF87a":
		return Gif.readGif(file)
	return null

bool ::outputFile([[RGB]]|null array, string filename):
	extension = stringSplit(filename, '.')[1]
	if array == null:
		return false
	if extension == "bmp":
		BMP.writeBMP(array, filename)
		return true
	else if extension  == "gif":
		Gif.writeGif(array, filename)
		return true
	else if extension == "png":
		PNG.writePNG(array, filename)
		return true
	return false


void ::printUsage(System.Console sys):
	sys.out.println("Command Line args")
	sys.out.println("-input <inputFile>")
	sys.out.println("-output <outputFile>")
	sys.out.println("-trans <List of Transforms>")
	sys.out.println("Note: Transformations must be the last arguments specified")

int parseInt(string s):
	try:
		return Int.parse(s)
	catch (SyntaxError e):
		return 0


[[RGB]] ::processTransformations([[RGB]] array, [string] args, int begin):
	if begin == -1:
		return array
	for i in begin..|args|:
		//Parse the Transform
		if args[i] == "-brighten":
			//Bring in Second Arguments
			bFactor = parseInt(args[i+1])
			debug "Brightening: " + bFactor + "\n"
			array = Transforms.brighten(array, bFactor)
			i = i+1
		else if args[i] == "-hue": 
			factor = parseInt(args[i+1])
			debug "Adjusting Hue: " + factor + "\n"
			array = Transforms.adjustHue(array, factor)
			i = i+1
		else if args[i] == "-contrast": 
			factor = parseInt(args[i+1])
			debug "Adjusting Contrast: " + factor + "\n"
			array = Transforms.contrast(array, factor)
			i = i+1
		else if args[i] == "-sat": 
			factor = parseInt(args[i+1])
			debug "Adjusting Saturation: " + factor + "\n"
			array = Transforms.adjustSaturation(array, factor)
			i = i+1
	return array

void ::main(System.Console sys):
	sys.out.println("Image Conversion. Supported Input formats: BMP, GIF. Supported Output Formats: BMP")
	if |sys.args| == 0:
		sys.out.println("No Input or Output file Specified. Exiting...")
		printUsage(sys)
		return
	else if |sys.args| == 1:
		sys.out.println("No Output File Specified. Exiting...")
		printUsage(sys)
		return
	
	inputFile = ""
	outputFile = ""
	transBegin = -1
	//Parse Commandline Arguments
	for i in 0..|sys.args|:
		if sys.args[i] == "-input":
			i = i+1
			inputFile = sys.args[i]
		else if sys.args[i] == "-output":
			i =  i+1
			outputFile = sys.args[i]
		else if sys.args[i] == "-trans":
			transBegin = i
			break
	sys.out.println("Transformations begin at: " + transBegin)
	
	dArray = processInputFile(inputFile)
	if dArray == null:
		sys.out.println("Input File Format not supported")
		return
	dArray = processTransformations(dArray, sys.args, transBegin)
	outputFile(dArray, outputFile)