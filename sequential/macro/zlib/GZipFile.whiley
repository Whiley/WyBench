import whiley.lang.*

define GZipFile as {
    int method,           // compression method (8 == Deflate)
    int mtime,            // modification time
    string|null filename, // filename (optional)
    [byte] data
}


public GZipFile GZipFile([byte] data) throws string:
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

    index = 10

    debug "CM: " + CM + "\n"
    debug "FLG: " + FLG + "\n"
    
    if FNAME:
        // filename is provided so extract it
        start = index
        while data[index] != 0b:
            index = index + 1
        filename = String.fromASCII(data[start..index])
        index = index + 1
    else:
        filename = null
        
    debug "FILENAME: " + filename + "\n"
    
    return {
        method: CM,
        mtime: 0,
        filename: filename,
        data: []
    }
    
