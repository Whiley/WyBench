import * from whiley.lang.*
import * from whiley.io.File
import RGB from Util
import Reader from BitBuffer
 
public [[RGB]] ::readPNG(File.Reader file):
	//Verification Checking
	debug "Processing PNG\n"
	s = String.fromASCII(file.read(3))
	if s != "PNG":
		debug "PNG HEADER MISSING. RETURNING\n"
		return [[]]
	debug "Past Header Verification:\n"
	//TODO: Deal with what these are for. 
	file.read(2)
	file.read(1)
	file.read(1)
	
	imageWidth = -1
	imageHeight = -1
	bitDepth = -1
	colorType = -1
	compression = -1
	filter = -1
	interlace = -1
	palette = []
	//After reading the header. We're now into reading the chunks
	loop = true
	while loop:
		
		length = Util.toSignedInt(file.read(4))
		
		headerType = String.fromASCII(file.read(4))
		data = file.read(length)
		crc = file.read(4)
		debug "" + headerType + " (" + length + ") - " + crc + "\n"
		if Util.equalsIgnoreCase(headerType, "IHDR"):
			//Need to parse header
			imageWidth = Util.toSignedInt(data[0..4])
			imageHeight = Util.toSignedInt(data[5..8])
			bitDepth = Util.toSignedInt([data[8]])
			colorType = Util.toSignedInt([data[9]])
			compression = Util.toSignedInt([data[10]])
			filter = Util.toSignedInt([data[11]])
			interlace = Util.toSignedInt([data[12]])
		else if Util.equalsIgnoreCase(headerType, "PLTE"):
			//Read in the Palette
			i = 0
			while i < |data|:
				palette = palette + [{r: Byte.toUnsignedInt(data[i]), g: Byte.toUnsignedInt(data[i+1]), b:Byte.toUnsignedInt(data[i+2])}]
				i = i+2
		else if Util.equalsIgnoreCase(headerType, "IDAT"):
			debug "Reading Image Data. Length: " + length + "\n"
			
		else if Util.equalsIgnoreCase(headerType, "IEND"):
			loop = false
		
	debug "File Information. Width: " + imageWidth + " Height: " + imageHeight + " bitDepth: " + bitDepth + " colorType: " + colorType
	debug " Compression Type: " + compression + " Filter: " + filter + " Interlace: " + interlace + "\n"
	debug "Palette: " + palette + "\n"
	
	return [[]]
	
	
public void ::writePNG([[RGB]] array, string filename):
	writer = File.Writer(filename)
	
	writer.write(List.reverse(Int.toUnsignedBytes(0x89504e470d0a1a0a))) // PNG Signature
	//Write the IHDR Chunk.
	length = 13
	title = "IHDR"
	data = []
	data = data + Util.padSignedInt(|array|, 4)
	data = data + Util.padSignedInt(|array[0]|, 4)
	data = data + Util.padSignedInt(8, 1)
	data = data + Util.padSignedInt(6, 1)
	data = data + [00000000b, 00000000b, 00000000b]
	debug "DATA WRITING: " + data + "\n"
	writer.write(Util.padSignedInt(length, 4))
	writer.write(Util.stringToByte(title))
	writer.write(data)
	writer.write(CRC.computeCRC32(Util.stringToByte(title)+data))
	//For Simplicities Sake. Assume 8 bit color, therefore, no palette
	
	title = "IDAT"
	bytes = compressPNGImage(array)
	length = |bytes|
	debug "WRITING IMAGE DATA: " + bytes + "\n"
	writer.write(Util.padSignedInt(length, 4))
	writer.write(Util.stringToByte(title))
	writer.write(data)
	writer.write(CRC.computeCRC32(Util.stringToByte(title)+data))
	
	title = "IEND"
	length = 0
	writer.write(Util.padSignedInt(length, 4))
	writer.write(Util.stringToByte(title))
	writer.write(Util.padSignedInt(0,4))
	
	
	writer.close()
	
[byte] compressPNGImage([[RGB]] array):
	//First thing, turn the data into a single array of bytes
	data = []
	data = data + List.reverse(Int.toUnsignedBytes(0x789C)) 
	for i in 0..|array[0]|:
		for j in 0..|array|:
			data = data + Int.toUnsignedBytes(array[i][j].r)
			data = data + Int.toUnsignedBytes(array[i][j].g)
			data = data + Int.toUnsignedBytes(array[i][j].b)
			//data = data + Int.toUnsignedBytes(255) // Alpha
	reader = BitBuffer.Reader(data, 0)
	try:
		return Deflate.decompress(reader)
	catch (Error e):
		debug "ERROR: " + e.msg + "\n"
		return [00000000b]