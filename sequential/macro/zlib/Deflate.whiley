import whiley.lang.*
import * from BitTree

public [byte] decompress(BitBuffer.Reader reader):
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

BitBuffer.Reader readDynamicHuffmanCodes(BitBuffer.Reader reader):
    // first, read header information
    HLIT,reader = BitBuffer.read(reader,5)   // # of Literal/Length codes - 257 
    HDIST,reader = BitBuffer.read(reader,5)  // # of Distance codes - 1 
    HCLEN,reader = BitBuffer.read(reader,4)  // # of Code Length codes - 4    
    // second, read code lengths of code length alphabet
    lengthCodes,reader = readCodeLengthTree(reader,HCLEN)
    // now wtf?
    return reader

// See Section 3.2.7 from rfc1951 for more on this sequence!
define codeLengthMap as [16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]

(BitTree,BitBuffer.Reader) readCodeLengthTree(BitBuffer.Reader reader, byte HCLEN):
    codeLengths = []
    len = Byte.toUnsignedInt(HCLEN)+4
    // first, read raw code lengths
    for i in 0..len:
        b,reader = BitBuffer.read(reader,3)
        clen = Byte.toUnsignedInt(b)
        codeLengths = codeLengths + [clen]    
    // second, expand code lengths to form huffman codes
    codes = defineHuffmanCodes(codeLengths)
    // third, construct bitinary tree, whilst remembering that the codes
    // are not stored in the obvious manner.
    tree = Empty()
    for i in 0..|codes|:
        symbol = codes[i]
        code = codeLengthMap[i]
        tree = add(tree,code,symbol)
    // done
    return tree

