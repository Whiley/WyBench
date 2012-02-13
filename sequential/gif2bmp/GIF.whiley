import * from whiley.lang.System
import * from whiley.io.File
import Error from whiley.lang.Errors 

import * from BitBuffer

define RGB as {int r, int g, int b}
define RGBA as {int r, int g, int b, int a}

// RGB constructor
public RGB RGB(int red, int green, int blue):
    return {r: red, g: green, b: blue}

define Header as {
    string magic,
    int width,
    int height,
    int bitsPerPixel,
    int bitsOfResolution,
    bool hasGlobalMap,
    int background
}

define Descriptor as {
    int left,
    int top,
    int width,
    int height,
    int bitsPerPixel,
    bool interlaced
}

void read([byte] data) throws Error:
    reader = Reader(data,0)
    // read header
    header,reader = readHeader(reader)
    // read colour map (if present)
    if header.hasGlobalMap:
        globalColourMap,reader = readColourMap(reader,header.bitsPerPixel)
    else:
        throw Error("need to implement default colour map")
    // read contents of this file
    while true:
        lookahead,reader = read(reader,8)
        switch lookahead:
            case 0010000b:
                // GIF Extension Block
                reader = skipExtensionBlock(reader)
            case 00101100b:
                // Image Descriptor
                image = readImageDescriptor(reader,globalColourMap)
            case 00111011b:
                // Terminator
                break

// read the GIF header
(Header,Reader) readHeader(Reader reader) throws Error:
    // read magic number
    magic = ""
    for i in 0..6:
        b,reader = read(reader,8)
        i = Byte.toUnsignedInt(b)
        magic = magic + (char)i
    // check magic number seems sensible
    if magic[0..3] != "GIF":
        throw Error("invalid magic number - " + magic)
    // read logical screen resolution
    width,reader = readUnsignedInt(reader,16)
    height,reader = readUnsignedInt(reader,16)    
    // read bits/pixel in image
    bitsPerPixel,reader = readUnsignedInt(reader,3)  
    bitsPerPixel = bitsPerPixel + 1
    // read dummy bit
    dummy,reader = read(reader)        
    // read bits of colour resolution
    bitsOfColourResolution,reader = readUnsignedInt(reader,3)    
    bitsOfColourResolution = bitsOfColourResolution+1
    // read global bit
    global,reader = read(reader)        
    // read background colour index
    background,reader = readUnsignedInt(reader,8)
    // read dummy bits
    dummy,reader = read(reader,8)
    // done
    return {
        magic: magic,
        width: width,
        height: height,
        bitsPerPixel: bitsPerPixel,
        bitsOfResolution: bitsOfColourResolution,
        hasGlobalMap: global,
        background: background        
    },reader

Reader skipExtensionBlock(Reader reader):
    code,reader = readUnsignedInt(reader,8)
    count,reader = readUnsignedInt(reader,8)
    while count != 0:
        while count > 0:
            dummy,reader = readUnsignedInt(reader,8)
            count = count - 1
        count,reader = readUnsignedInt(reader,8)    
    return reader
            
(Descriptor,Reader) readImageDescriptor(Reader reader, [RGB] globalColourMap) throws Error:
    // read image dimensions
    left,reader = readUnsignedInt(reader,16)
    top,reader = readUnsignedInt(reader,16)
    width,reader = readUnsignedInt(reader,16)
    height,reader = readUnsignedInt(reader,16)
    // read bits per pixel
    bitsPerPixel,reader = readUnsignedInt(reader,3)  
    bitsPerPixel = bitsPerPixel + 1
    // read dummy bits
    dummy,reader = read(reader,3)
    // read interlave bit
    interlaced,reader = read(reader)        
    // read global bit
    lct,reader = read(reader)   
    // read local colour map
    if lct:
        colourMap,reader = readColourMap(reader,bitsPerPixel)
    else:
        colourMap = globalColourMap
    // now, we need to decode the lzw data    
    reader = decodeImageData(reader,width*height)    
    // done
    return {
        left: left,
        top: top,
        width: width,
        height: height,
        bitsPerPixel: bitsPerPixel,
        interlaced: interlaced
    },reader     

Reader decodeImageData(Reader reader, int numPixels):
    codeSize,reader = readUnsignedInt(reader,8)
    // first, initialise suffix and prefix maps
    suffix = []
    prefix = []
    // second, read blocks until none left
    count,reader = readUnsignedInt(reader,8)
        

// read a colour map
([RGB],Reader) readColourMap(Reader reader, int bitsPerPixel):
    ncols = Math.pow(2,bitsPerPixel)
    colourTable = []
    for i in 0..ncols:
        red,reader = readUnsignedInt(reader,8)
        green,reader = readUnsignedInt(reader,8)
        blue,reader = readUnsignedInt(reader,8)
        colourTable = colourTable + [RGB(red,green,blue)]
    // done
    return colourTable,reader

public void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
    contents = file.read()
    try:
        read(contents)
    catch(Error e):
        sys.out.println("Error: " + e)
    
