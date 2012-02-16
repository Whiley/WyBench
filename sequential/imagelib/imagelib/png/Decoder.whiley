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
        debug "GOT: " + Byte.toUnsignedInt(bytes[0]) + "\n"
        debug "GOT: " + Int.toHexString(Byte.toUnsignedInt(bytes[0])) + "\n"
        debug "GOT: " + Int.toHexString(Byte.toUnsignedInt(bytes[0..8])) + "\n"
        debug "WANTED: " + Int.toHexString(PNG_MAGIC) + "\n"
        throw Error("invalid PNG file (bad signature)")
    // second, read chunks
    pos = 8
    chunks = []
    while pos < |bytes|:
        chunk,pos = decodeChunk(bytes,pos)
        chunks = chunks + [chunk]
    return {
        chunks: chunks
    }

public (Chunk,int) decodeChunk([byte] bytes,int pos):
    length = Byte.toUnsignedInt(bytes[pos+4..pos])
    pos = pos + 4
    type = Byte.toUnsignedInt(bytes[pos..pos+4])
    debug String.fromASCII(bytes[pos..pos+4]) + " : " + Int.toHexString(type) + "\n"
    pos = pos + 4
    switch type:
        case IHDR_TYPE:
            chunk = decodeIHDR(bytes,pos)
        case IEND_TYPE:
            chunk = decodeIEND(bytes,pos)
        case PLTE_TYPE:
            chunk = decodePLTE(bytes,pos,length)
        case PHYS_TYPE:
            chunk = decodePHYS(bytes,pos)
        case TIME_TYPE:
            chunk = decodeTIME(bytes,pos)
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
        compressionMethod: compression,
        filterMethod: filter,
        interlaceMethod: interlace
    }

public Chunk decodeIEND([byte] bytes, int pos):
    return {
        type: IEND_TYPE,
        data: []
    }

// the Pallette length must be divisible by three
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

public PHYS decodePHYS([byte] bytes, int pos):
    xppu = Byte.toUnsignedInt(bytes[pos+4..pos])
    yppu = Byte.toUnsignedInt(bytes[pos+8..pos+4])
    unit = Byte.toUnsignedInt(bytes[pos+8])
    return {
        xPixelsPerUnit: xppu,
        yPixelsPerUnit: yppu,
        unit: unit
    }

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
