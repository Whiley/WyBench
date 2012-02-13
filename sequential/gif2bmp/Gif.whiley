import * from whiley.lang.Errors
import * from whiley.lang.System
import * from whiley.io.File
import * from BitBuffer

define Error as {string msg}

public define RGB as {int r, int g, int b}
define RGBA as {int r, int g, int b, int a}

// RGB constructor
public RGB RGB(int red, int green, int blue):
    return {r: red, g: green, b: blue}

define Descriptor as {
    int left,
    int top,
    int width,
    int height,
    int bitsPerPixel,
    bool interlaced
}

void read([byte] data) throws Error:
    pos = 0

    // ===============================================
    // Read GIF header
    // ===============================================
    magic = ""
    for i in 0..6:
        i = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        magic = magic + (char)i
    // check magic number seems sensible
    if magic[0..3] != "GIF":
        throw Error("invalid magic number - " + magic)
    // read logical screen resolution
    width,reader = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    height,reader = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    // read packed data
    packed = data[pos]
    bitsPerPixel = Byte.toUnsignedInt(packed & 111b)
    bitsOfColourResolution = Byte.toUnsignedInt((packed & 01110000b) >> 4)
    hasGlobalMap = (packed & 10000000b) != 0b
    pos = pos + 1
    // read background colour index
    background = data[pos]    
    
    // ===============================================
    // Read Global Colour Map (if present)
    // ===============================================
    if hasGlobalMap:
        globalColourMap,pos = readColourMap(data,pos,bitsPerPixel)
    else:
        throw Error("need to implement default colour map")

    // ===============================================
    // Read Contents
    // ===============================================
    while true:
        lookahead = data[pos]
        pos = pos + 1
        switch lookahead:
            case 0010000b:
                // GIF Extension Block
                pos = skipExtensionBlock(data,pos)
            case 00101100b:
                // Image Descriptor
                image,pos = readImageDescriptor(data,pos,globalColourMap)
            case 00111011b:
                // Terminator
                break

int skipExtensionBlock([byte] data, int pos):
    code = Byte.toUnsignedInt(data[pos])
    pos = pos + 1
    count = Byte.toUnsignedInt(data[pos])
    pos = pos + 1
    while count != 0:
        pos = pos + count
        count = Byte.toUnsignedInt(data[pos])
    return pos
            
(Descriptor,int) readImageDescriptor([byte] data, int pos, [RGB] globalColourMap) throws Error:
    // read image dimensions
    left,reader = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    top,reader = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    width,reader = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    height,reader = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    // read packed data
    packed = data[pos]
    bitsPerPixel = Byte.toUnsignedInt(packed & 111b)
    interlaced = (packed & 01000000b) != 0b
    hasLocalMap = (packed & 10000000b) != 0b
    pos = pos + 1
    // read local colour map
    if hasLocalMap:
        colourMap,reader = readColourMap(data,pos,bitsPerPixel)
    else:
        colourMap = globalColourMap
    // now, we need to decode the lzw data    

    // done
    return {
        left: left,
        top: top,
        width: width,
        height: height,
        bitsPerPixel: bitsPerPixel,
        interlaced: interlaced
    },pos

Reader decodeImageData(Reader reader, int numPixels):
    codeSize,reader = BitBuffer.readUnsignedInt(reader,8)
    // first, initialise suffix and prefix maps
    suffix = []
    prefix = []
    // second, read blocks until none left
    count,reader = readUnsignedInt(reader,8)
        

// read a colour map
([RGB],int) readColourMap([byte] data, int pos, int bitsPerPixel):
    ncols = Math.pow(2,bitsPerPixel)
    colourTable = []
    for i in 0..ncols:
        red,reader = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        green,reader = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        blue,reader = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        colourTable = colourTable + [RGB(red,green,blue)]
    // done
    return colourTable,pos

public void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
    contents = file.read()
    try:
        read(contents)
    catch(Error e):
        sys.out.println("Error: " + e)
    
