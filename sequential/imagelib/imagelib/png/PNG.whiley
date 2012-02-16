// Copyright (c) 2011, David J. Pearce
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

// An implementation of PNG ISO/IEC 15948:2003 (E).  
// See: http://www.w3.org/TR/2003/REC-PNG-20031110/
//
// NOTE: comments highlighted from PNG ISO/IEC 15948:2003 (E) are (C) W3C

package imagelib.png

import Error from whiley.lang.Errors
import u32 from whiley.lang.Int
import u16 from whiley.lang.Int
import u8 from whiley.lang.Int

import zlib.io.ZLib // for decompression.

define PNG_MAGIC as 0x0A1A0A0D474E5089

// ==============================================================================
// PNG
// ==============================================================================

define PNG as {
    [Chunk] chunks
}

// Decode a stream of bytes representing a PNG file.  Note, that this
// does not decompress the given image and a subsequent call to
// decompress is needed for this.
public PNG decode([byte] bytes) throws Error:
    return Decoder.decode(bytes)

// Decompress a given PNG file to generat the image it represents.
public [byte] decompress(PNG png) throws Error:
    data = []
    // first, accumulate all data
    for chunk in png.chunks:
        if chunk is IDAT:
            data = data + chunk.data
    // second, decompress the full data
    return ZLib.decompress(data)

// ==============================================================================
// Chunk
// ==============================================================================

public define Chunk as IHDR | IDAT | PLTE | PHYS | TIME | SRGB | RAW

// the RAW chunk is provided to protect against future extensions to the standard.
public define RAW as {
    u32 type,   
    [byte] data
}

// ==============================================================================
// IHDR
// ==============================================================================
//
// The IHDR chunk shall be the first chunk in the PNG datastream. It
// contains:
//
//  ----------------------------
//  Width 	       | 4 bytes
//  Height 	       | 4 bytes
//  Bit depth 	       | 1 byte
//  Colour type        | 1 byte
//  Compression method | 1 byte
//  Filter method      | 1 byte
//  Interlace method   | 1 byte
//  ----------------------------
//
// Width and height give the image dimensions in pixels. They are PNG
// four-byte unsigned integers. Zero is an invalid value.
//
// Bit depth is a single-byte integer giving the number of bits per
// sample or per palette index (not per pixel). Valid values are 1, 2, 4,
// 8, and 16, although not all values are allowed for all colour
// types.
//
// Colour type is a single-byte integer that defines the PNG image
// type. Valid values are 0, 2, 3, 4, and 6.
//
// Bit depth restrictions for each colour type are imposed to simplify
// implementations and to prohibit combinations that do not compress
// well. 
//
// The sample depth is the same as the bit depth except in the case of
// indexed-colour PNG images (colour type 3), in which the sample depth
// is always 8 bits
//
// Compression method is a single-byte integer that indicates the method
// used to compress the image data. 
//
// Filter method is a single-byte integer that indicates the
// preprocessing method applied to the image data before
// compression. 
//
// Interlace method is a single-byte integer that indicates the
// transmission order of the image data. Two values are defined in this
// International Standard: 0 (no interlace) or 1 (Adam7 interlace). See
// clause 8: Interlacing and pass extraction for details.
//
// -- PNG ISO/IEC 15948:2003 (E)

define IHDR_TYPE as 0x52444849

public define GREYSCALE as 0
public define TRUECOLOR as 2
public define INDEXCOLOR as 3
public define GREYSCALE_WITH_ALPHA as 4
public define TRUECOLOR_WITH_ALPHA as 6

public define BitDepth as int where $ in {1,2,4,8,16}

public define ColorType as {
    GREYSCALE,
    TRUECOLOR,
    INDEXCOLOR,
    GREYSCALE_WITH_ALPHA,
    TRUECOLOR_WITH_ALPHA    
}

public define ValidColorDepths as [
    {1,2,4,8,16}, // GREYSCALE
    {},           // (empty)
    {8,16},       // TRUECOLOR
    {1,2,4,8},    // INDEXCOLOR
    {8,16},       // greyscale with alpha
    {},           // (empty)
    {8,16}        // truecolor with alpha
]

public define ZLIB as 0
public define OTHER as 1

// Currently, only zlib compression is defined for PNG
public define CompressionMethod as { ZLIB, OTHER }

public define IHDR as { // Image Header
    u32 width,
    u32 height,
    BitDepth bitDepth,
    ColorType colorType,
    CompressionMethod  compression,
    u8  filterMethod,
    u8  interlaceMethod
} where width > 0 && height > 0 && bitDepth in ValidColorDepths[colorType]

public IHDR IHDR(u32 width, u32 height, BitDepth bitDepth, ColorType colorType, CompressionMethod compression, u8 filterMethod, u8 interlaceMethod):
    return {
        width: width,
        height: height,
        bitDepth: bitDepth,
        colorType: colorType,
        compression: compression,
        filterMethod: filterMethod,
        interlaceMethod: interlaceMethod
    }

// ==============================================================================
// IEND
// ==============================================================================

public define IEND_TYPE as 0x444e4549

// ==============================================================================
// IDAT
// ==============================================================================
//
// The IDAT chunk contains the actual image data which is the output
// stream of the compression algorithm.
//
public define IDAT_TYPE as 0x54414449

public define IDAT as {
    [byte] data // compressed (partial) data
}

// ==============================================================================
// PLTE
// ==============================================================================
//
// The PLTE chunk contains from 1 to 256 palette entries, each a
// three-byte series of the form:
//
// --------------
// Red 	 | 1 byte
// Green | 1 byte
// Blue  | 1 byte
// --------------
//
// The number of entries is determined from the chunk length. A chunk
// length not divisible by 3 is an error.
//
// This chunk shall appear for colour type 3, and may appear for
// colour types 2 and 6; it shall not appear for colour types 0 and
// 4. There shall not be more than one PLTE chunk.
//
// For colour type 3 (indexed-colour), the PLTE chunk is required. The
// first entry in PLTE is referenced by pixel value 0, the second by
// pixel value 1, etc. The number of palette entries shall not exceed the
// range that can be represented in the image bit depth (for example, 24
// = 16 for a bit depth of 4). It is permissible to have fewer entries
// than the bit depth would allow. In that case, any out-of-range pixel
// value found in the image data is an error.
//
// For colour types 2 and 6 (truecolour and truecolour with alpha), the
// PLTE chunk is optional. If present, it provides a suggested set of
// colours (from 1 to 256) to which the truecolour image can be quantized
// if it cannot be displayed directly. It is, however, recommended that
// the sPLT chunk be used for this purpose, rather than the PLTE
// chunk. If neither PLTE nor sPLT chunks are present and the image
// cannot be displayed directly, quantization has to be done by the
// viewing system. However, it is often preferable for the selection of
// colours to be done once by the PNG encoder. (See 12.6: Suggested
// palettes.)
//
// Note that the palette uses 8 bits (1 byte) per sample regardless of
// the image bit depth. In particular, the palette is 8 bits deep even
// when it is a suggested quantization of a 16-bit truecolour image.
//
// There is no requirement that the palette entries all be used by the
// image, nor that they all be different.
//
// -- PNG ISO/IEC 15948:2003 (E)
//
public define PLTE_TYPE as 0x45544c50

public define RGB as {
    u8 red,
    u8 green,
    u8 blue
}

public RGB RGB(u8 red, u8 green, u8 blue):
    return {
        red: red,
        green: green,
        blue: blue
    }

public define PLTE as { // Palette
    [RGB] colors
}

public PLTE PLTE([RGB] colors):
    return {
        colors: colors
    }

// ==============================================================================
// sRGB
// ==============================================================================
//
// If the sRGB chunk is present, the image samples conform to the sRGB
// colour space [IEC 61966-2-1] and should be displayed using the
// specified rendering intent defined by the International Color
// Consortium [ICC-1] and [ICC-1A].
//
// The sRGB chunk contains:
//
//     -------------------------
//     Rendering intent | 1 byte
//     -------------------------
//
// The following values are defined for rendering intent:
//
// 0 | Perceptual   | for images preferring good adaptation to the output
//   |              | device gamut at the expense of colorimetric accuracy, 
//   |              | such as photographs.
// -----------------------------------------------------------------------
// 1 | Relative     | for images requiring colour appearance
//   | colorimetric | matching (relative to the output device white point), 
//   |              | such as logos.
// -----------------------------------------------------------------------
// 2 | Saturation   | for images preferring preservation of saturation at
//   |              | the expense of hue and lightness, such as charts and 
//   |              | graphs.
// -----------------------------------------------------------------------
// 3 | Absolute     | for images requiring preservation of absolute
//   | colorimetric | colorimetry, such as previews of images destined for 
//   |              | a different output device (proofs).
//
// It is recommended that a PNG encoder that writes the sRGB chunk also
// write a gAMA chunk (and optionally a cHRM chunk) for compatibility
// with decoders that do not use the sRGB chunk. Only the following
// values shall be used.
//
// -- PNG ISO/IEC 15948:2003 (E)
//
public define SRGB_TYPE as 0x42475273

// for images preferring good adaptation to the output device gamut at
// the expense of colorimetric accuracy, such as photographs.
public define PERCEPTUAL as 0

// for images requiring colour appearance matching (relative to the
// output device white point), such as logos.
public define RELATIVE_COLORIMETRIC as 1

// for images preferring preservation of saturation at the expense of
// hue and lightness, such as charts and graphs.
public define SATURATION as 2

// for images requiring preservation of absolute colorimetry, such as
// previews of images destined for a different output device (proofs).
public define ABSOLUTE_COLORIMETRIC as 3

public define RenderingIntent as { 
    PERCEPTUAL, 
    RELATIVE_COLORIMETRIC, 
    SATURATION, 
    ABSOLUTE_COLORIMETRIC 
}

public define SRGB as {
    RenderingIntent intent
}

// ==============================================================================
// pHYs
// ==============================================================================
//
// The pHYs chunk specifies the intended pixel size or aspect ratio for
// display of the image. It contains:
//
//     --------------------------------------------------------
//     Pixels per unit, X axis | 4 bytes (PNG unsigned integer)
//     Pixels per unit, Y axis | 4 bytes (PNG unsigned integer)
//     Unit specifier 	       | 1 byte
//     --------------------------------------------------------
//
// The following values are defined for the unit specifier:
//
//     0 	unit is unknown
//     1 	unit is the metre
//
// When the unit specifier is 0, the pHYs chunk defines pixel aspect
// ratio only; the actual size of the pixels remains unspecified.
//
// If the pHYs chunk is not present, pixels are assumed to be square, and
// the physical size of each pixel is unspecified.
//
// -- PNG ISO/IEC 15948:2003 (E)
//
public define PHYS_TYPE as 0x73594870

public define UNKNOWN as 0
public define METERS as 1
public define Unit as { UNKNOWN, METERS }

public define PHYS as {
    u32 xPixelsPerUnit,
    u32 yPixelsPerUnit,
    Unit unit 
}

// ==============================================================================
// tIME
// ==============================================================================
//
// The tIME chunk gives the time of the last image modification (not the
// time of initial image creation). It contains:
//
//     ------------------------------------------------------
//     Year   | 2 bytes (complete; for example, 1995, not 95)
//     Month  | 1 byte (1-12)
//     Day    | 1 byte (1-31)
//     Hour   | 1 byte (0-23)
//     Minute | 1 byte (0-59)
//     Second | 1 byte (0-60) (to allow for leap seconds)
//     ------------------------------------------------------
//
// Universal Time (UTC) should be specified rather than local time.
//
// The tIME chunk is intended for use as an automatically-applied time
// stamp that is updated whenever the image data are changed.
//
// -- PNG ISO/IEC 15948:2003 (E)
//
public define TIME_TYPE as 0x454d4974

public define TIME as {
    u16 year,
    u8 month,
    u8 day,
    u8 hour,
    u8 minute,
    u8 second
} where 1 <= month && month <= 12 &&
    1 <= day && day <= 31 && // could presumably do better here
    0 <= hour && hour <= 23 &&
    0 <= minute && minute <= 59 &&
    0 <= second && second <= 60 // 60 to allow for leap seconds
    


