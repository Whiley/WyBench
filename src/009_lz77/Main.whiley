/**
 * A simplistic implementation of the Lempel-Ziv 77 compressions/decompression.
 *
 * See: http://en.wikipedia.org/wiki/LZ77_and_LZ78
 */

import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*

define nat as int where $ >= 0

[byte] compress([byte] data):
    pos = 0
    output = []
    // keep going until all data matched
    while pos < |data| where pos >= 0:
        (offset,len) = findLongestMatch(data,pos)
        output = write_u1(output,offset)
        if offset == 0:
            output = output + [data[pos]]
            pos = pos + 1
        else:
            output = write_u1(output,len)
            pos = pos + len
    // done!
    return output

// pos is current position in input value
(nat,nat) findLongestMatch([byte] data, nat pos):
    bestOffset = 0
    bestLen = 0
    start = pos - 255
    if start < 0:
        start = 0
    //start = Math.max(pos - 255,0)
    assert start >= 0
    offset = start
    while offset < pos where bestOffset >= 0 && bestLen >= 0 && offset >= 0:
        len = match(data,offset,pos)
        if len > bestLen:
            bestOffset = pos - offset
            bestLen = len
        offset = offset + 1
    //
    return bestOffset,bestLen

int match([byte] data, nat offset, nat end):
    pos = end
    len = 0
    while offset < pos && pos < |data| && data[offset] == data[pos] where pos >= 0 && offset >= 0:
        offset = offset + 1
        pos = pos + 1
        len = len + 1
    return len

[byte] decompress([byte] data):
    output = []
    pos = 0
    while (pos+1) < |data| where pos >= 0:
        offset = data[pos]
        item = data[pos+1]
        pos = pos + 2
        if offset == 00000000b:
            output = output + [item]
        else:
            offset = Byte.toUnsignedInt(offset)
            len = Byte.toUnsignedInt(item)
            start = |output| - offset
            // How to avoid these assumptions?
            assume offset <= |output|
            assume (start+len) < |output|
            i = start
            while i < (start+len):
                item = output[i]
                output = output + [item]       
                i = i + 1     
    // all done!
    return output
            
[byte] write_u1([byte] bytes, int u1):
    return bytes + [Int.toUnsignedByte(u1)]

void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
    data = file.read()
    sys.out.println("READ:         " + |data| + " bytes")
    data = compress(data)
    sys.out.println("COMPRESSED:   " + |data| + " bytes.")
    data = decompress(data)
    sys.out.println("UNCOMPRESSED: " + |data| + " bytes")
    sys.out.println("==================================")
    sys.out.print(String.fromASCII(data))



