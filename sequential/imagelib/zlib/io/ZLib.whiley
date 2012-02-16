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
package zlib.io

import Error from whiley.lang.Errors
import zlib.core.Deflate

// Compression Methods
public define DEFLATE as 8 

// Compression Levels
public define FASTEST as 0 
public define FAST as 1
public define DEFAULT as 2
public define MAXIMUM as 3

// zlib stream
public define Header as {
    int CM,         // Compression Method
    int CINFO,      // Compression Info
    int FLEVEL,     // Compression Level
    int|null DICTID // Dictionary identifier
}

public Header decodeHeader([byte] data):
    CMF = data[0]
    CM = Byte.toUnsignedInt(CMF & 1111b)
    CINFO = Byte.toUnsignedInt(CMF >> 4)
    FLG = data[1]
    
    FCHECK = (FLG & 00001111b)
    FDICT  = (FLG & 00010000b) != 0b
    FLEVEL = Byte.toUnsignedInt((FLG >> 6) & 11b)

    if FDICT:
        DICTID = Byte.toUnsignedInt(data[2 .. 6])
    else:
        DICTID = null
    // done
    return {
        CM: CM,
        CINFO: CINFO,
        FLEVEL: FLEVEL,
        DICTID: DICTID
    }

// Decompress an entire stream
public [byte] decompress([byte] data) throws Error:
    CMF = data[0]
    CM = Byte.toUnsignedInt(CMF & 1111b)
    CINFO = Byte.toUnsignedInt(CMF >> 4)
    FLG = data[1]
    
    FCHECK = (FLG & 00001111b)
    FDICT  = (FLG & 00010000b) != 0b
    FLEVEL = Byte.toUnsignedInt((FLG >> 6) & 11b)

    if FDICT:
        DICTID = data[2 .. 6]
        index = 6
    else:
        DICTID = null
        index = 2
        
    // now decompress the actual data
    data = Deflate.decompress(data[index..])    

    // finally, return a GZipFile record
    return data
