import whiley.lang.*

define GZipFile as {
    int method, // Compression Method
    int info,   // Compression info
    int level,  // Compression Level
    int mtime,  // modification time
    [byte] data
}


public GZipFile GZipFile([byte] data) throws string:
    // first, check magic number
    ID1 = Byte.toUnsignedInt(data[0])
    ID2 = Byte.toUnsignedInt(data[1])
    if ID1 != 31 || ID2 != 139:
        throw "invalid gzip file"
    CMF = data[2]
    FLG = data[3]
    
    method = Byte.toUnsignedInt(CMF & 1111b)
    info = Byte.toUnsignedInt(CMF >> 4)
    check = FLG & 1111b
    dict = (FLG & 10000b) != 0b
    level = Byte.toUnsignedInt(FLG >> 6)
    debug "COMPRESSION METHOD " + method + "\n"
    return {
        method: method,
        info: info,
        level: level,
        mtime: 0,
        data: []
    }
    
