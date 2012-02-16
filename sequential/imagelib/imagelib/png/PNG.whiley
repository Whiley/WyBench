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
import u32 from whiley.lang.Int
import u8 from whiley.lang.Int

define PNG_MAGIC as 0x0A1A0A0D474E5089

// ==============================================================================
// PNG
// ==============================================================================

define PNG as {
    [Chunk] chunks
}

public PNG decode([byte] bytes) throws Error:
    return Decoder.decode(bytes)

// ==============================================================================
// Chunk
// ==============================================================================

public define Chunk as IHDR | PLTE | RAW

// the RAW chunk is provided to protect against future extensions to the standard.
public define RAW as {
    u32 type,   
    [byte] data
}

// ==============================================================================
// IHDR
// ==============================================================================

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

public define IHDR as { // Image Header
    u32 width,
    u32 height,
    BitDepth bitDepth,
    ColorType colorType,
    u8  compressionMethod,
    u8  filterMethod,
    u8  interlaceMethod
} where width > 0 && height > 0 && bitDepth in ValidColorDepths[colorType]

public IHDR IHDR(u32 width, u32 height, BitDepth bitDepth, ColorType colorType, u8 compressionMethod, u8 filterMethod, u8 interlaceMethod):
    return {
        width: width,
        height: height,
        bitDepth: bitDepth,
        colorType: colorType,
        compressionMethod: compressionMethod,
        filterMethod: filterMethod,
        interlaceMethod: interlaceMethod
    }

// ==============================================================================
// IEND
// ==============================================================================

public define IEND_TYPE as 0x444e4549

// ==============================================================================
// PLTE
// ==============================================================================

define PLTE_TYPE as 0x45544c50

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










