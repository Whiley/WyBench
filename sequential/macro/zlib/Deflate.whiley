import whiley.lang.*

public [byte] decompress(BitBuffer.Reader reader):
    output = []
    BFINAL = false // slightly annoying
    do:
        // read block header
        BFINAL,reader = BitBuffer.read(reader)
        BTYPE,reader = BitBuffer.read(reader,2)        

        if BTYPE == 0b:
            // stored with no compression
            debug "STORED WITH NO COMRESSION"
        else:
            if BTYPE == 10b:
                // using dynamic Huffman codes
                trees = readCodeTrees()
            // now read the block
            endOfBlock = false
            while !endOfBlock:
                value = decodeValue()
                if value < 256:
                    // indicates a literal
                    output = output + [Int.toUnsignedByte(value)]
                else if value == 256:
                    // end of block
                    endOfBlock = true
                else:
                    // figure out distance
                                    
            // done reading block
    while !BFINAL
    return []
