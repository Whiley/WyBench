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
package zlib.util

import whiley.lang.*

define Reader as {
    int index,  // index of current byte in data
    int boff,    // bit offset in current byte
    [byte] data 
}

public Reader Reader([byte] data, int start):
    return {
        index: start,
        boff: 0,
        data: data
    }

public (bool,Reader) read(Reader reader):
    boff = reader.boff
    // first, read the current bit
    b = reader.data[reader.index]
    b = b >> boff
    b = b & 00000001b
    // now, move position to next bit
    boff = boff + 1
    if boff == 8:
        reader.boff = 0
        reader.index = reader.index + 1
    else:
        reader.boff = boff
    // return the bit we've read
    return b == 00000001b,reader

public (byte,Reader) read(Reader reader, int nbits) requires nbits >= 0 && nbits < 8:
    mask = 00000001b
    r = 0b
    for i in 0..nbits:
        bit,reader = read(reader)
        if bit:
            r = r | mask
        mask = mask << 1
    return r,reader

// read zero or more bytes directly off the stream.  
public ([byte],Reader) readBytes(Reader reader, int nbytes) requires nbytes > 0:
    if reader.boff == 0:
        // can perform a direct copy (faster)
        start = reader.index
        end = start + nbytes
        reader.index = end
        return reader.data[start .. end],reader
    else:
        // can't perform a direct copy (slower)
        bytes = []
        while nbytes > 0:
            b,reader = read(reader,8)
            bytes = bytes + [b]
            nbytes = nbytes - 1
        return bytes,reader

public (int,Reader) readUnsignedInt(Reader reader, int nbits):
    base = 1
    r = 0
    for i in 0..nbits:
        bit,reader = read(reader)
        if bit:
            r = r + base
        base = base * 2
    return r,reader

// Move to the next byte boundary, whilst skipping over any remaining
// bits in the current byte.  If we're already on a byte boundary, then
// do nothing.
public Reader skipToByteBoundary(Reader reader):
    if reader.boff != 0:
        reader.boff = 0
        reader.index = reader.index + 1
    return reader

define Writer as {
    int index,  // index of current byte in data
    int boff,    // bit offset in current byte
    [byte] data 
}

public Writer Writer():
    return {
        index: 0,
        boff: 0,
        data: []
    }

public Writer write(Writer writer, bool bit):
    // first, check there's enough space
    index = writer.index
    boff = writer.boff
    if index >= |writer.data|:
        writer.data = writer.data + [00000000b]
    // second, write the bit out
    if bit:
        mask = 00000001b << boff
        writer.data[index] = writer.data[index] | mask
    // third, update offsets
    boff = boff + 1
    if boff == 8:
        writer.boff = 0
        writer.index = writer.index + 1
    else:
        writer.boff = boff
    // done!
    return writer
