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

package imagelib.png

import Error from whiley.lang.Errors
import * from imagelib.png.*

// Decode a stream of bytes representing a PNG file.
public PNG decode([byte] bytes) throws Error:
    // first, check magic    
    if Byte.toUnsignedInt(bytes[0..8]) != PNG_MAGIC:
        throw Error("invalid PNG file (bad signature)")
    // second, read chunks
    pos = 8
    // IHDR
    header,pos = decodeChunk(bytes,pos)
    if !(header is IHDR):
        throw Error("invalid PNG file (should start with IHDR)")
    // REST
    data = []
    colors = []
    while pos < |bytes|:
        chunk,pos = decodeChunk(bytes,pos)
        if chunk is IDAT:
            data = data + chunk.data
        else if chunk is PLTE:
            colors = chunk.colors
    // finally, construct PNG abstraction
    return {
        // from IHDR
        width: header.width,
        height: header.height,
        bitDepth: header.bitDepth,
        colorType: header.colorType,
        compression: header.compression,
        filterMethod: header.filterMethod,
        interlaceMethod: header.interlaceMethod,
        // from PLTE
        colors: colors,
        // from IDAT(s)
        data: data
    }

// ==============================================================================
// CHUNK
// ==============================================================================

public (Chunk,int) decodeChunk([byte] bytes,int pos) throws Error:
    length = Byte.toUnsignedInt(bytes[pos+4..pos])
    pos = pos + 4
    type = Byte.toUnsignedInt(bytes[pos..pos+4])
    pos = pos + 4
    switch type:
        case IHDR_TYPE:
            chunk = decodeIHDR(bytes,pos)
        case IEND_TYPE:
            chunk = decodeIEND(bytes,pos)
        case IDAT_TYPE:
            chunk = decodeIDAT(bytes,pos,length)
        case PLTE_TYPE:
            chunk = decodePLTE(bytes,pos,length)
        case PHYS_TYPE:
            chunk = decodePHYS(bytes,pos)
        case TIME_TYPE:
            chunk = decodeTIME(bytes,pos)
        case SRGB_TYPE:
            chunk = decodeSRGB(bytes,pos)
        default:
            // unknown chunk
            chunk = {
                type: type,
                data: bytes[pos..pos+length]
            }            
    // finally, check CRC
    pos = pos + length
    crc = Byte.toUnsignedInt(bytes[pos+4..pos])
    // done
    return chunk,pos+4

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
public IHDR decodeIHDR([byte] bytes, int pos):
    width = Byte.toUnsignedInt(bytes[pos+4..pos])
    height = Byte.toUnsignedInt(bytes[pos+8..pos+4])
    depth = Byte.toUnsignedInt(bytes[pos+8])
    type = Byte.toUnsignedInt(bytes[pos+9])
    compression = Byte.toUnsignedInt(bytes[pos+10])
    filter = Byte.toUnsignedInt(bytes[pos+11])
    interlace = Byte.toUnsignedInt(bytes[pos+12])    
    return {
        width: width,
        height: height,
        bitDepth: depth,
        colorType: type,
        compression: compression,
        filterMethod: filter,
        interlaceMethod: interlace
    }

// ==============================================================================
// IEND
// ==============================================================================

public Chunk decodeIEND([byte] bytes, int pos):
    return {
        type: IEND_TYPE,
        data: []
    }

// ==============================================================================
// IDAT
// ==============================================================================
//
// The IDAT chunk contains the actual image data which is the output
// stream of the compression algorithm.

public IDAT decodeIDAT([byte] bytes, int pos, int length) throws Error:
    return {
        data: bytes[pos..pos+length]
    }

// ==============================================================================
// PLTE
// ==============================================================================

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
public PLTE decodePLTE([byte] bytes, int pos, int length) requires (length % 3) == 0:
    length = length / 3
    colors = []
    for i in 0..length:
        red = Byte.toUnsignedInt(bytes[pos])
        pos = pos + 1
        green = Byte.toUnsignedInt(bytes[pos])
        pos = pos + 1
        blue = Byte.toUnsignedInt(bytes[pos])
        pos = pos + 1
        colors = colors + [RGB(red,green,blue)]
    return {
        colors: colors
    }

// ==============================================================================
// pHYs
// ==============================================================================
//
// The pHYs chunk contains:
//
//     --------------------------------------------------------
//     Pixels per unit, X axis | 4 bytes (PNG unsigned integer)
//     Pixels per unit, Y axis | 4 bytes (PNG unsigned integer)
//     Unit specifier 	       | 1 byte
//     --------------------------------------------------------
//
public PHYS decodePHYS([byte] bytes, int pos):
    xppu = Byte.toUnsignedInt(bytes[pos+4..pos])
    yppu = Byte.toUnsignedInt(bytes[pos+8..pos+4])
    unit = Byte.toUnsignedInt(bytes[pos+8])
    return {
        xPixelsPerUnit: xppu,
        yPixelsPerUnit: yppu,
        unit: unit
    }

// ==============================================================================
// tIME
// ==============================================================================
//
// The tIME chunk contains:
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
public TIME decodeTIME([byte] bytes, int pos):
    year = Byte.toUnsignedInt(bytes[pos+2..pos])
    month = Byte.toUnsignedInt(bytes[pos+2])
    day = Byte.toUnsignedInt(bytes[pos+3])
    hour = Byte.toUnsignedInt(bytes[pos+4])
    minute = Byte.toUnsignedInt(bytes[pos+5])
    second = Byte.toUnsignedInt(bytes[pos+6])
    return {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second
    }

// ==============================================================================
// sRGB
// ==============================================================================
//
// The sRGB chunk contains:
//
//     -------------------------
//     Rendering intent | 1 byte
//     -------------------------
//
public SRGB decodeSRGB([byte] bytes, int pos):
    intent = Byte.toUnsignedInt(bytes[pos])
    return {
        intent: intent
    }