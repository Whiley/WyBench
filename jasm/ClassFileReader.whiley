define FormatError as {string msg}

define ReaderState as {
    [byte] bytes,
    [int] items,
    [JvmConstant] pool
}

ClassFile|FormatError readClassFile([byte] data):
    
