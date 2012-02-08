/**
 * A simplistic implementation of the Lempel-Ziv 77 compressions/decompression.
 *
 * See: http://en.wikipedia.org/wiki/LZ77_and_LZ78
 */

import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*

[byte] compress([byte] data):
    pos = 0
    output = []
    // keep going until all data matched
    while pos < |data|:
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
(int,int) findLongestMatch([byte] data, int pos):
    bestOffset = 0
    bestLen = 0
    start = Math.max(pos-255,0)
    for offset in start .. pos:
        len = match(data,offset,pos)
        if len > bestLen:
            bestOffset = pos-offset
            bestLen = len
    return bestOffset,bestLen

int match([byte] data, int offset, int end):
    pos = end
    len = 0
    while offset < pos && pos < |data| && data[offset] == data[pos]:
        offset = offset + 1
        pos = pos + 1
        len = len + 1
    return len

[byte] decompress([byte] data):
    output = []
    pos = 0
    while pos < |data|:
        offset = data[pos]
        item = data[pos+1]
        pos = pos + 2
        if offset == 00000000b:
            output = output + [item]
        else:
            offset = Byte.toUnsignedInt(offset)
            len = Byte.toUnsignedInt(item)
            start = |output| - offset
            for i in start .. (start+len):
                item = output[i]
                output = output + [item]            
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



