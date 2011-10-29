import whiley.lang.*
import Error from whiley.lang.Errors

define GZipFile as {
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
    
