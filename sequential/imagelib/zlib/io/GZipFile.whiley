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

import whiley.lang.*
import Error from whiley.lang.Errors
import zlib.core.*
import zlib.util.*

public define GZipFile as {
    int method,           // compression method (8 == Deflate)
    int mtime,            // modification time
    string|null filename, // filename (optional)
    [byte] data
}

public GZipFile GZipFile([byte] data) throws string|Error:
    // first, check magic number
    ID1 = Byte.toUnsignedInt(data[0])
    ID2 = Byte.toUnsignedInt(data[1])
    if ID1 != 31 || ID2 != 139:
        throw "invalid gzip file"

    CM = Byte.toUnsignedInt(data[2])
    FLG = data[3]
    
    FTEXT     = (FLG & 00000001b) != 0b
    FHCRC     = (FLG & 00000010b) != 0b
    FEXTRA    = (FLG & 00000100b) != 0b
    FNAME     = (FLG & 00001000b) != 0b
    FCOMMENT  = (FLG & 00010000b) != 0b
    MTIME = Byte.toUnsignedInt(data[4..8])

    index = 10
    if FNAME:
        // filename is provided so extract it
        start = index
        while data[index] != 0b:
            index = index + 1
        filename = String.fromASCII(data[start..index])
        index = index + 1
    else:
        filename = null

    // now decompress the actual data
    data = Deflate.decompress(BitBuffer.Reader(data,index))    

    // finally, return a GZipFile record
    return {
        method: CM,
        mtime: MTIME,
        filename: filename,
        data: data
    }
    
