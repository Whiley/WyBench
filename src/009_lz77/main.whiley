/**
 * A simplistic implementation of the Lempel-Ziv 77 compressions/decompression.
 *
 * See: http://en.wikipedia.org/wiki/LZ77_and_LZ78
 */
import std.ascii
import std.filesystem
import std.integer
import std.io
import std.math

type nat is (int x) where x >= 0

function compress(byte[] data) -> byte[]:
    nat pos = 0
    byte[] output = [0b; 0]
    //
    // keep going until all data matched
    while pos < |data| where pos >= 0:
        int offset
        int len
        offset,len = findLongestMatch(data,pos)
        output = write_u1(output,offset)
        if offset == 0:
            output = append(output,data[pos])
            pos = pos + 1
        else:
            output = write_u1(output,len)
            pos = pos + len
    // done!
    return output

// pos is current position in input value
function findLongestMatch(byte[] data, nat pos) -> (nat offset, nat length)
    ensures offset >= 0 && offset <= 255
    ensures length >= 0 && length <= 255:
    //
    nat bestOffset = 0
    nat bestLen = 0
    int start = math.max(pos - 255,0)
    assert start >= 0
    nat index = start
    while index < pos
        where index >= 0 && pos >= 0 && bestOffset >= 0 && bestLen >= 0
        where bestOffset <= 255 && pos - index <= 255 && bestLen <= 255:
        //
        int len = match(data,index,pos)
        if len > bestLen:
            bestOffset = pos - index
            bestLen = len
        index = index + 1
    //
    return bestOffset,bestLen

function match(byte[] data, nat offset, nat end) -> (int length)
    ensures 0 <= length && length <= 255:
    //
    nat pos = end
    nat len = 0
    //
    while offset < pos && pos < |data| && data[offset] == data[pos] && len < 255
        where offset >= 0 && pos >= 0 && len >= 0 && len <= 255:
        //
        offset = offset + 1
        pos = pos + 1
        len = len + 1
    //
    return len

function decompress(byte[] data) -> byte[]:
    byte[] output = [0b;0]
    nat pos = 0
    //
    while (pos+1) < |data| where pos >= 0:
        byte header = data[pos]
        byte item = data[pos+1]
        pos = pos + 2 
        if header == 00000000b:
            output = append(output,item)
        else:
            int offset = integer.toUnsignedInt(header)
            int len = integer.toUnsignedInt(item)
            int start = |output| - offset
            // How to avoid these assumptions?
            //assume offset <= |data|
            //assume (start+len) < |data|
            //assume start >= 0
            //assume start < |output|
            int i = start
            while i < (start+len) where i >= 0 && i < |output|:
                item = output[i]
                output = append(output,item)
                i = i + 1     
    // all done!
    return output

function write_u1(byte[] bytes, int u1) -> byte[]
    requires u1 >= 0 && u1 <= 255:
    //
    return append(bytes,integer.toUnsignedByte(u1))

method main(ascii.string[] args):
    filesystem.File file = filesystem.open(args[0],filesystem.READONLY)
    byte[] data = file.readAll()
    io.print("READ:         ")
    io.print(|data|)
    io.println(" bytes")
    data = compress(data)
    io.print("COMPRESSED:   ")
    io.print(|data|)
    io.println(" bytes")
    data = decompress(data)
    io.print("UNCOMPRESSED:   ")
    io.print(|data|)
    io.println(" bytes")
    io.println("==================================")
    io.print(ascii.fromBytes(data))

// This is temporary and should be removed
public function append(byte[] items, byte item) -> (byte[] ritems)
    ensures |ritems| == |items| + 1:
    //
    byte[] nitems = [0b; |items| + 1]
    int i = 0
    //
    while i < |items|
        where i >= 0 && i <= |items|
        where |nitems| == |items| + 1:
        //
        nitems[i] = items[i]
        i = i + 1
    //
    nitems[i] = item    
    //
    return nitems

