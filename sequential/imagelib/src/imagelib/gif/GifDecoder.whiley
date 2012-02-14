package imagelib.gif

import * from whiley.lang.Errors
import * from whiley.lang.System
import * from whiley.io.File
import * from BitBuffer
import RGB from imagelib.core.Color

// RGB constructor
public define GIF as {  
    [Image] images
}

define Image as {
    int left,
    int top,
    int width,
    int height,
    int bitsPerPixel,
    bool interlaced,
    [RGB] data
}

public GIF read([byte] data) throws Error:
    pos = 0

    // ===============================================
    // GIF SIGNATURE
    // ===============================================

    magic = ""
    for i in 0..6:
        i = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        magic = magic + (char)i
    // check magic number seems sensible
    if magic[0..3] != "GIF":
        throw Error("invalid magic number - " + magic)

    // ===============================================
    // SCREEN DESCRIPTOR
    //
    //       bits
    //  7 6 5 4 3 2 1 0  Byte #
    // +---------------+
    // |	       |  1
    // +-Screen Width -+      Raster width in pixels (LSB first)
    // |	       |  2
    // +---------------+
    // |	       |  3
    // +-Screen Height-+      Raster height in pixels (LSB first)
    // |	       |  4
    // +-+-----+-+-----+      M = 1, Global color map follows Descriptor
    // |M|  cr |0|pixel|  5   cr+1 = # bits of color resolution
    // +-+-----+-+-----+      pixel+1 = # bits/pixel in image
    // |   background  |  6   background=Color index of screen background
    // +---------------+	   (color is defined from the Global color
    // |0 0 0 0 0 0 0 0|  7	    map or default map if none specified)
    // +---------------+
    //
    // ===============================================

    // read logical screen resolution
    width = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    height = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    // read packed data
    packed = data[pos]
    bitsPerPixel = Byte.toUnsignedInt(packed & 111b) + 1
    bitsOfColourResolution = Byte.toUnsignedInt((packed & 01110000b) >> 4)
    hasGlobalMap = (packed & 10000000b) != 0b
    pos = pos + 1
    // read background colour index
    background = data[pos]    
    pos = pos + 1
    // skip zero byte
    pos = pos + 1

    // ===============================================
    // GLOBAL COLOUR MAP (if present)
    // ===============================================

    if hasGlobalMap:
        debug "READING GLOBAL COLOUR MAP: " + bitsPerPixel + "\n"
        globalColourMap,pos = readColourMap(data,pos,bitsPerPixel)
    else:
        throw Error("need to implement default colour map")

    // ===============================================
    // CONTENTS
    // ===============================================
    images = []
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
                images = images + [image]
            case 00111011b:
                // Terminator
                break    
    // done
    return { images: images }

// GIF EXTENSION BLOCK
//
//      To provide for orderly extension of the GIF definition, a mechanism
// for defining  the  packaging  of extensions within a GIF data stream is
// necessary.  Specific GIF extensions are to be defined and documented  by
// CompuServe in order to provide a controlled enhancement path.
//      GIF Extension Blocks are packaged in a manner similar to that  used
// by the raster data though not compressed.  The basic structure is:
//
//         7 6 5 4 3 2 1 0  Byte #
//
//        +---------------+
//        |0 0 1 0 0 0 0 1|  1	   '!' - GIF Extension Block Introducer
//        +---------------+
//        | function code |  2	   Extension function code (0 to 255)
//        +---------------+    ---+
//        |  byte count	|	|
//        +---------------+	|
//        :		:	+-- Repeated as many times as necessary
//        |func data bytes|	|
//        :		:	|
//        +---------------+    ---+
//        . . .	    . . .
//        +---------------+
//        |0 0 0 0 0 0 0 0|	zero byte count (terminates block)
//        +---------------+
//
//      A GIF Extension Block may immediately preceed any Image  Descriptor
// or occur before the GIF Terminator.
//      All GIF decoders must be able to recognize  the  existence  of	GIF
// Extension  Blocks  and  read past them if unable to process the function
// code.  This ensures that older decoders will be able to process extended
// GIF image	 files	 in  the  future,  though  without  the  additional
// functionality.
int skipExtensionBlock([byte] data, int pos):
    code = Byte.toUnsignedInt(data[pos])
    pos = pos + 1
    count = Byte.toUnsignedInt(data[pos])
    pos = pos + 1
    while count != 0:
        pos = pos + count
        count = Byte.toUnsignedInt(data[pos])
    return pos

// IMAGE DESCRIPTOR
//
// The Image Descriptor defines the actual placement  and	extents  of
// the	following  image within the space defined in the Screen Descriptor.
// Also defined are flags to indicate the presence of a local color  lookup
// map, and to define the pixel display sequence.  Each Image Descriptor is
// introduced by an image separator  character.   The  role  of  the  Image
// Separator  is simply to provide a synchronization character to introduce
// an Image Descriptor.  This is desirable if a GIF file happens to contain
// more  than  one  image.   This  character  is defined as 0x2C hex or ','
// (comma).  When this character is encountered between images,  the  Image
// Descriptor will follow immediately.
// any characters encountered between the end of a previous image	and
// the image separator character are to be ignored.  This allows future GIF
// enhancements to be present in newer image formats and yet ignored safely
// by older software decoders.
//
// 	      bits
// 	 7 6 5 4 3 2 1 0  Byte #
// 	+---------------+
// 	|0 0 1 0 1 1 0 0|  1	',' - Image separator character
// 	+---------------+
// 	|		|  2	Start of image in pixels from the
// 	+-  Image Left -+	left side of the screen (LSB first)
// 	|		|  3
// 	+---------------+
// 	|		|  4
// 	+-  Image Top  -+	Start of image in pixels from the
// 	|		|  5	top of the screen (LSB first)
// 	+---------------+
// 	|		|  6
// 	+- Image Width -+	Width of the image in pixels (LSB first)
// 	|		|  7
// 	+---------------+
// 	|		|  8
// 	+- Image Height-+	Height of the image in pixels (LSB first)
// 	|		|  9
// 	+-+-+-+-+-+-----+	M=0 - Use global color map, ignore 'pixel'
// 	|M|I|0|0|0|pixel| 10	M=1 - Local color map follows, use 'pixel'
// 	+-+-+-+-+-+-----+	I=0 - Image formatted in Sequential order
// 				I=1 - Image formatted in Interlaced order
// 				pixel+1 - # bits per pixel for this image
//
//  The specifications for the image position and size must be confined
// to  the  dimensions defined by the Screen Descriptor.  On the other hand
// it is not necessary that the image fill the entire screen defined.
//
// LOCAL COLOR MAP
//
//  A Local Color Map is optional and defined here for future use.	 If
// the	'M' bit of byte 10 of the Image Descriptor is set, then a color map
// follows the Image Descriptor that applies only to the  following  image.
// At the end of the image, the color map will revert to that defined after
// the Screen Descriptor.  Note that the 'pixel' field of byte	10  of	the
// Image  Descriptor  is used only if a Local Color Map is indicated.  This
// defines the parameters not only for the image pixel size, but determines
// the	number	of color map entries that follow.  The bits per pixel value
// will also revert to the value specified in the  Screen  Descriptor  when
// processing of the image is complete.
//
// RASTER DATA
//
//  The format of the actual image is defined as the  series  of  pixel
// color  index  values that make up the image.  The pixels are stored left
// to right sequentially for an image row.  By default each  image  row  is
// written  sequentially, top to bottom.  In the case that the Interlace or
// 'I' bit is set in byte 10 of the Image Descriptor then the row order  of
// the	image  display	follows  a  four-pass process in which the image is
// filled in by widely spaced rows.  The first pass writes every  8th  row,
// starting  with  the top row of the image window.  The second pass writes
// every 8th row starting at the fifth row from the top.   The	third  pass
// writes every 4th row starting at the third row from the top.  The fourth
// pass completes the image, writing  every  other  row,  starting  at	the
// second row from the top. 
(Image,int) readImageDescriptor([byte] data, int pos, [RGB] globalColourMap) throws Error:
    // read image dimensions
    left = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    top = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    width = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    height = Byte.toUnsignedInt(data[pos..pos+2])
    pos = pos + 2
    // read packed data
    packed = data[pos]
    bitsPerPixel = Byte.toUnsignedInt(packed & 111b) + 1  
    interlaced = (packed & 01000000b) != 0b
    hasLocalMap = (packed & 10000000b) != 0b
    pos = pos + 1
    // read local colour map
    if hasLocalMap:
        colourMap,reader = readColourMap(data,pos,bitsPerPixel)
    else:
        colourMap = globalColourMap
    // now, decode the lzw data    
    indexData,pos = decodeImageData(data,pos,width*height)
    // convert from colour indices into rgb data
    rgbData = []
    for index in indexData:
        rgbData = rgbData + [colourMap[index]]
    // done
    return {
        left: left,
        top: top,
        width: width,
        height: height,
        bitsPerPixel: bitsPerPixel,
        interlaced: interlaced,
        data: rgbData
    },pos

// Appendix C - Image Packaging & Compression
//
//   The Raster Data stream that represents the actual output image can
// be represented as:
//
// 	 7 6 5 4 3 2 1 0
// 	+---------------+
// 	|   code size	|
// 	+---------------+     ---+
// 	|blok byte count|	 |
// 	+---------------+	 |
// 	:		:	 +-- Repeated as many times as necessary
// 	|  data bytes	|	 |
// 	:		:	 |
// 	+---------------+     ---+
// 	. . .	    . . .
// 	+---------------+
// 	|0 0 0 0 0 0 0 0|	zero byte count (terminates data stream)
// 	+---------------+
//
//   The conversion of the image from a series  of  pixel  values  to  a
// transmitted or stored character stream involves several steps.  In brief
// these steps are:
//
//  1.  Establish the Code Size -  Define  the  number  of  bits  needed  to
//      represent the actual data.
//  2.  Compress the Data - Compress the series of image pixels to a  series
//      of compression codes.
//  3.  Build a Series of Bytes - Take the  set	of  compression  codes	and
//      convert to a string of 8-bit bytes.
//  4.  Package the Bytes - Package sets of bytes into blocks  preceeded  by
//      character counts and output.
//
// ESTABLISH CODE SIZE
//
//   The first byte of the GIF Raster Data stream is a value  indicating
// the minimum number of bits required to represent the set of actual pixel
// values.  Normally this will be the same as the  number  of  color  bits.
// Because  of	some  algorithmic constraints however, black & white images
// which have one color bit must be indicated as having a code size  of  2.
// This  code size value also implies that the compression codes must start
// out one bit longer.
//
// COMPRESSION
//
//   The LZW algorithm converts a series of data values into a series of
// codes  which may be raw values or a code designating a series of values.
// Using text characters as an analogy,  the  output  code  consists  of  a
// character or a code representing a string of characters.
//   The LZW algorithm used in  GIF	matches  algorithmically  with	the
// standard LZW algorithm with the following differences:
//
//  1.  A   special   Clear   code   is	  defined    which    resets	all
//      compression/decompression parameters and tables to a start-up state.
//      The value of this code is 2**<code size>.  For example if  the  code
//      size  indicated	was 4 (image was 4 bits/pixel) the Clear code value
//      would be 16 (10000 binary).  The Clear code can appear at any  point
//      in the image data stream and therefore requires the LZW algorithm to
//      process succeeding codes as if  a  new  data  stream  was  starting.
//      Encoders  should output a Clear code as the first code of each image
//      data stream.
//  2.  An End of Information code is defined that explicitly indicates	the
//      end  of	the image data stream.	LZW processing terminates when this
//      code is encountered.  It must be the last code output by the encoder
//      for an image.  The value of this code is <Clear code>+1.
//  3.  The first available compression code value is <Clear code>+2.
//  4.  The output codes are of variable length, starting  at  <code size>+1
//      bits  per code, up to 12 bits per code.	This defines a maximum code
//      value of 4095 (hex FFF).  Whenever the LZW code value  would  exceed
//      the  current  code length, the code length is increased by one.	The
//      packing/unpacking of these codes must then be altered to reflect the
//      new code length.
([int],int) decodeImageData([byte] data, int pos, int numPixels):    
    //  establish code size
    codeSize = Byte.toUnsignedInt(data[pos])
    pos = pos + 1
    clearCode = Math.pow(2,codeSize)
    endOfInformation = clearCode + 1
    codeSizeLimit = clearCode * 2
    codeSize = codeSize + 1

    // initialise code and index tables
    codes = []
    for i in 0 .. clearCode + 2:
        codes = codes + [[i]]
    
    // initialise working values for codeSize, clearCode and EOI
    currentCodeSize = codeSize
    available = clearCode + 2
    currentCodeSizeLimit = codeSizeLimit
    
    stream = [] // raster data stream to be produced
    old = [] // old code value initially null
    reader = BlockBuffer.Reader(data,pos)

    while true:            
        // read next code
        code,reader = BlockBuffer.readUnsignedInt(reader,currentCodeSize)    
        // now decode it
        if code == clearCode:
            // reset the code table
            currentCodeSize = codeSize
            currentCodeSizeLimit = codeSizeLimit
            available = clearCode + 2
            codes = codes[0 .. available]    
            old = []
        else if code == endOfInformation:
            // indicates we're done
            break
        else if old == []:
            stream = stream + codes[code]
            old = codes[code]
            // continue
        else:
            next = []
            if code < available:
                // Yes, code is in table!
                current = codes[code]
                next = old + [current[0]]
                stream = stream + current
                old = current
            else if code == available:
                // No, code is not in table :(
                next = old + [old[0]]
                stream = stream + next                
                old = next
            codes = codes + [next]   
            available = available + 1
            // check whether code table is full
            if available == currentCodeSizeLimit:
                // code size limit reached
                currentCodeSize = currentCodeSize + 1
                currentCodeSizeLimit = currentCodeSizeLimit * 2                           
    // end while        
    pos = reader.index
    if reader.boff != 0: 
        pos = pos + 1 // discard excess bits

    return stream,pos

// GLOBAL COLOR MAP
//
//  The Global Color Map is optional but recommended for  images  where
// accurate color rendition is desired.  The existence of this color map is
// indicated in the 'M' field of byte 5 of the Screen Descriptor.  A  color
// map	can  also  be associated with each image in a GIF file as described
// later.  However this  global  map  will  normally  be  used	because  of
// hardware  restrictions  in equipment available today.  In the individual
// Image Descriptors the 'M' flag will normally be  zero.   If	the  Global
// Color  Map  is  present,  it's definition immediately follows the Screen
// Descriptor.	 The  number  of  color  map  entries  following  a  Screen
// Descriptor  is equal to 2**(# bits per pixel), where each entry consists
// of three byte values representing the relative intensities of red, green
// and blue respectively.  The structure of the Color Map block is:
//
// 	      bits
// 	 7 6 5 4 3 2 1 0  Byte #
// 	+---------------+
// 	| red intensity |  1	Red value for color index 0
// 	+---------------+
// 	|green intensity|  2	Green value for color index 0
// 	+---------------+
// 	| blue intensity|  3	Blue value for color index 0
// 	+---------------+
// 	| red intensity |  4	Red value for color index 1
// 	+---------------+
// 	|green intensity|  5	Green value for color index 1
// 	+---------------+
// 	| blue intensity|  6	Blue value for color index 1
// 	+---------------+
// 	:		:	(Continues for remaining colors)
//
//  Each image pixel value received will be displayed according to	its
// closest match with an available color of the display based on this color
// map.  The color components represent a fractional intensity	value  from
// none  (0)  to  full (255).  White would be represented as (255,255,255),
// black as (0,0,0) and medium yellow as (180,180,0).  For display, if	the
// device  supports fewer than 8 bits per color component, the higher order
// bits of each component are used.  In the creation of  a  GIF  color	map
// entry  with	hardware  supporting  fewer  than 8 bits per component, the
// component values for the hardware  should  be  converted  to  the  8-bit
// format with the following calculation:
//
// 	<map_value> = <component_value>*255/(2**<nbits> -1)
//
// This assures accurate translation of colors for all  displays.	 In
// the	cases  of  creating  GIF images from hardware without color palette
// capability, a fixed palette should be created  based  on  the  available
// display  colors for that hardware.  If no Global Color Map is indicated,
// a default color map is generated internally	which  maps  each  possible
// incoming  color  index to the same hardware color index modulo <n> where
// <n> is the number of available hardware colors.
([RGB],int) readColourMap([byte] data, int pos, int bitsPerPixel):
    ncols = Math.pow(2,bitsPerPixel)
    colourTable = []
    for i in 0..ncols:
        red = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        green = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        blue = Byte.toUnsignedInt(data[pos])
        pos = pos + 1
        colourTable = colourTable + [RGB(red,green,blue)]
    // done
    return colourTable,pos
