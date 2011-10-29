import whiley.lang.*
import Error from whiley.lang.Errors

define State as {
    Huffman.Tree literalLengths,
    Huffman.Tree distances
}

public [byte] decompress(BitBuffer.Reader reader) throws Error:
    output = []
    BFINAL = false // slightly annoying
    while !BFINAL:
        // read block header
        BFINAL,reader = BitBuffer.read(reader)
        BTYPE,reader = BitBuffer.read(reader,2)        

        if BTYPE == 0b:
            // stored with no compression
            debug "STORED WITH NO COMRESSION"
        else:
            if BTYPE == 10b:
                // using dynamic Huffman codes
                reader = readDynamicHuffmanCodes(reader)
            // now read the block
            // endOfBlock = false
            // while !endOfBlock:
            //     value = decodeValue()
            //     if value < 256:
            //         // indicates a literal
            //         output = output + [Int.toUnsignedByte(value)]
            //     else if value == 256:
            //         // end of block
            //         endOfBlock = true
            //     else:
                    // figure out distance                                    
            // done reading block
    // finally, return uncompressed data
    return output

BitBuffer.Reader readDynamicHuffmanCodes(BitBuffer.Reader reader) throws Error:
    // first, read header information
    HLIT,reader = BitBuffer.read(reader,5)   // # of Literal/Length codes - 257 
    HDIST,reader = BitBuffer.read(reader,5)  // # of Distance codes - 1 
    HCLEN,reader = BitBuffer.read(reader,4)  // # of Code Length codes - 4    
    // convert bytes into integers
    HCLEN = Byte.toUnsignedInt(HCLEN)+4
    HLIT = Byte.toUnsignedInt(HLIT)+257
    HDIST = Byte.toUnsignedInt(HDIST)+1
    // second, read code lengths of code length alphabet
    lengthCodes,reader = readLengthCodes(reader,HCLEN)
    debug "READ: " + Huffman.size(lengthCodes) + " SYMBOLS\n"
    debug "READING: " + (HLIT+HDIST) + " lengths\n"
    lengths,reader = readLengths_HLIT_HDIST(reader,lengthCodes,HLIT + HDIST)
    debug "READ: " + |lengths| + " LENGTHS\n"
    // now wtf?
    return reader

// Read the code lengths for the HLIT and HDIST alphabets.  These form
// one continguous block of lengths, which we subsequently break up.
([int],BitBuffer.Reader) readLengths_HLIT_HDIST(BitBuffer.Reader reader, Huffman.Tree lengthCodes, int count) throws Error:
    lengths = []
    current = lengthCodes
    while |lengths| < count:
        bit,reader = BitBuffer.read(reader)
        current = Huffman.get(current,bit)
        if current == null:
            throw Error("decode error")
        else if current is int:
            // we have a symbol, now decide what to do with it.
            switch current:
                case 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15:
                    l = 1
                    c = current
                case 16:
                    // Copy the previous code length 3 - 6 times     
                    // (2 bits data)
                    l,reader = BitBuffer.read(reader,2)
                    l = Byte.toUnsignedInt(l)+3
                    c = lengths[|lengths|-1]
                case 17:
                    // Repeat a code length of 0 for 3 - 10 times
                    // (3 bits data)
                    l,reader = BitBuffer.read(reader,3)
                    l = Byte.toUnsignedInt(l)+3
                    c = 0
                case 18:
                    // Repeat a code length of 0 for 11 - 138 times
                    // (7 bits data)
                    l,reader = BitBuffer.read(reader,3)
                    l = Byte.toUnsignedInt(l)+11
                    c = 0
                default:
                    throw Error("unknown code length symbol encountered")
            // now do the actual copying
            for i in 0 .. l:
                lengths = lengths + [c]                        
            // now, reset huffman tree
            current = lengthCodes
        // done
    return lengths,reader

// See Section 3.2.7 from rfc1951 for more on this sequence!
define lengthCodeMap as [16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]

(Huffman.Tree,BitBuffer.Reader) readLengthCodes(BitBuffer.Reader reader, int len) throws Error:
    codeLengths = []
    // first, read raw code lengths
    for i in 0..len:
        b,reader = BitBuffer.read(reader,3)
        clen = Byte.toUnsignedInt(b)
        codeLengths = codeLengths + [clen]    
    // second, expand code lengths to form huffman codes
    codes = Huffman.generate(codeLengths)
    // third, construct bitinary tree, whilst remembering that the codes
    // are not stored in the obvious manner.
    tree = Huffman.Empty()
    for i in 0..|codes|:
        // FIXME: following is totally broken.
        code = codes[i]
        if code != null:
            symbol = lengthCodeMap[i]        
            tree = Huffman.put(tree,code,symbol)
    // done
    return tree,reader

