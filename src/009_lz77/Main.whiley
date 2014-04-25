/**
 * A simplistic implementation of the Lempel-Ziv 77 compressions/decompression.
 *
 * See: http://en.wikipedia.org/wiki/LZ77_and_LZ78
 */

import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*

type nat is (int x) where x >= 0

function compress([byte] data) => [byte]:
    nat pos = 0
    [byte] output = []
    //
    // keep going until all data matched
    while pos < |data| where pos >= 0:
        int offset, int len = findLongestMatch(data,pos)
        output = write_u1(output,offset)
        if offset == 0:
            output = output ++ [data[pos]]
            pos = pos + 1
        else:
            output = write_u1(output,len)
            pos = pos + len
    // done!
    return output

// pos is current position in input value
function findLongestMatch([byte] data, nat pos) => (nat,nat):
    //
    nat bestOffset = 0
    nat bestLen = 0
    int start = pos - 255
    if start < 0:
        start = 0
    //start = Math.max(pos - 255,0)
    assert start >= 0
    nat offset = start
    while offset < pos where offset >= 0 && pos >= 0 && bestOffset >= 0 && bestLen >= 0:
        //
        int len = match(data,offset,pos)
        if len > bestLen:
            bestOffset = pos - offset
            bestLen = len
        offset = offset + 1
    //
    return bestOffset,bestLen

function match([byte] data, nat offset, nat end) => int:
    nat pos = end
    nat len = 0
    //
    while offset < pos && pos < |data| && data[offset] == data[pos]
        where offset >= 0 && pos >= 0:
        //
        offset = offset + 1
        pos = pos + 1
        len = len + 1
    //
    return len

function decompress([byte] data) => [byte]:
    [byte] output = []
    nat pos = 0
    //
    while (pos+1) < |data| where pos >= 0:
        byte header = data[pos]
        byte item = data[pos+1]
        pos = pos + 2
        if header == 00000000b:
            output = output ++ [item]
        else:
            int offset = Byte.toUnsignedInt(header)
            int len = Byte.toUnsignedInt(item)
            int start = |output| - offset
            // How to avoid these assumptions?
            assume offset <= |output|
            assume (start+len) < |output|
            int i = start
            while i < (start+len) where i >= 0:
                item = output[i]
                output = output ++ [item]       
                i = i + 1     
    // all done!
    return output

function write_u1([byte] bytes, int u1) => [byte]:
    return bytes ++ [Int.toUnsignedByte(u1)]

method main(System.Console sys):
    File.Reader file = File.Reader(sys.args[0])
    [byte] data = file.readAll()
    sys.out.println("READ:         " ++ |data| ++ " bytes")
    data = compress(data)
    sys.out.println("COMPRESSED:   " ++ |data| ++ " bytes.")
    data = decompress(data)
    sys.out.println("UNCOMPRESSED: " ++ |data| ++ " bytes")
    sys.out.println("==================================")
    sys.out.print(String.fromASCII(data))



