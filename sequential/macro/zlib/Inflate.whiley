import whiley.lang.*

public [byte] decompress([byte] data):
    header,index = parseHeader(data)
    return []

public (ZLib.Header,int) parseHeader([byte] data):
    CMF = data[0]
    FLG = data[1]
    
    method = Byte.toUnsignedInt(CMF & 1111b)
    info = Byte.toUnsignedInt(CMF >> 4)
    check = FLG & 1111b
    dict = (FLG & 10000b) != 0b
    level = Byte.toUnsignedInt(FLG >> 6)
    
    return ZLib.Header(method,info,level),2
