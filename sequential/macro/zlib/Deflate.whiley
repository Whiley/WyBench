import whiley.lang.*
import Error from whiley.lang.Errors

// Corresponds to "EXTRA BITS" column of first table from Section
// 3.2.5 in RFC1951
define LENGTH_BITS as [
    0,    // 257
    0,    // 258
    0,    // 259
    0,    // 260
    0,    // 261
    0,    // 262
    0,    // 263
    0,    // 264
    1,    // 265
    1,    // 266
    1,    // 267
    1,    // 268
    2,    // 269
    2,    // 270
    2,    // 271
    2,    // 272
    3,    // 273
    3,    // 274
    3,    // 275
    3,    // 276
    4,    // 277
    4,    // 278
    4,    // 279
    4,    // 280
    5,    // 281
    5,    // 282
    5,    // 283
    5,    // 284    
    0     // 285
]

// Corresponds to "Length(s)" column of first table from Section 3.2.5
// in RFC1951
define LENGTH_BASES as [
    3,     // 257
    4,     // 258
    5,     // 259
    6,     // 260
    7,     // 261
    8,     // 262
    9,     // 263
    10,    // 264
    11,    // 265
    13,    // 266
    15,    // 267
    17,    // 268
    19,    // 269
    23,    // 270
    27,    // 271
    31,    // 272
    35,    // 273
    43,    // 274
    51,    // 275
    59,    // 276
    67,    // 277
    83,    // 278
    99,    // 279
    115,   // 280
    131,   // 281
    163,   // 282
    195,   // 283
    227,   // 284    
    258    // 285
]

// Corresponds to "Extra Bits" column of second table from Section
// 3.2.5 in RFC1951
define DISTANCE_BITS as [
    0,  // 0
    0,  // 1
    0,  // 2
    0,  // 3
    1,  // 4
    1,  // 5
    2,  // 6
    2,  // 7
    3,  // 8
    3,  // 9
    4,  // 10
    4,  // 11
    5,  // 12
    5,  // 13
    6,  // 14
    6,  // 15
    7,  // 16
    7,  // 17
    8,  // 18
    8,  // 19
    9,  // 20
    9,  // 21
    10, // 22
    10, // 23
    11, // 24
    11, // 25
    12, // 26
    12, // 27
    13, // 28
    13  // 29
]

// Corresponds to "Dist" column of second table from Section 3.2.5
// in RFC1951
define DISTANCE_BASES as [
    1,     // 0
    2,     // 1
    3,     // 2
    4,     // 3
    5,     // 4
    7,     // 5
    9,     // 6
    13,    // 7
    17,    // 8
    25,    // 9
    33,    // 10
    49,    // 11
    65,    // 12
    97,    // 13
    129,   // 14
    193,   // 15
    257,   // 16
    385,   // 17
    513,   // 18
    769,   // 19
    1025,  // 20
    1537,  // 21
    2049,  // 22
    3073,  // 23
    4097,  // 24
    6145,  // 25
    8193,  // 26
    12289, // 27
    16385, // 28
    24577  // 29
]

public [byte] decompress(BitBuffer.Reader reader) throws Error:
    output = []
    BFINAL = false 
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
                literals,distances,reader = readDynamicHuffmanCodes(reader)
            else:
                throw Error("FIXED HUFFMAN CODE ALPABET NOT YET SUPPORTED")
            // now read the block
            endOfBlock = false
            current = literals
            while !endOfBlock:
                bit,reader = BitBuffer.read(reader)
                current = Huffman.get(current,bit)
                if current == null:
                    throw Error("Decode error")
                else if current is int:
                    // literal matched
                    if current < 256:
                        // indicates a literal
                        output = output + [Int.toUnsignedByte(current)]
                    else if current == 256:
                        endOfBlock = true
                    else:                    
                        // ok, first figure out length
                        current = current - 257
                        extras,reader = BitBuffer.read(reader,LENGTH_BITS[current])
                        extras = Byte.toUnsignedInt(extras)
                        length = LENGTH_BASES[current] + extras
                        // second, figure out distance?
                        current = distances
                        while !(current is int):
                            bit,reader = BitBuffer.read(reader)
                            current = Huffman.get(current,bit)
                        if !(current is int):
                            throw Error("dead code") // hmmm, compiler bug?
                        extras,reader = BitBuffer.read(reader,DISTANCE_BITS[current])
                        extras = Byte.toUnsignedInt(extras)
                        distance = DISTANCE_BASES[current] + extras
                        // finally do the copy
                        start = |output| - distance
                        end = start + length
                        for i in start..end:
                            output = output + [output[i]]
                        // done!
                     // must reset huffman tree before continuing
                    current = literals
            // done reading block    
    // finally, return uncompressed data
    return output

(Huffman.Tree,Huffman.Tree,BitBuffer.Reader) readDynamicHuffmanCodes(BitBuffer.Reader reader) throws Error:
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
    // third, read the combined code lengths for literal and distance alphabets
    lengths,reader = readLengths_HLIT_HDIST(reader,lengthCodes,HLIT + HDIST)
    litLengths = lengths[0..HLIT]
    distLengths = lengths[HLIT..]
    // fourth, genereate huffman codes for literal and distances
    litCodes = Huffman.generate(litLengths)
    distCodes = Huffman.generate(distLengths)
    // fifth, construct corresponding huffman trees
    litTree = Huffman.Empty()
    for i in 0..|litCodes|:
        code = litCodes[i]
        if code != null:
            litTree = Huffman.put(litTree,code,i)
    // now distances
    distTree = Huffman.Empty()
    for i in 0..|distCodes|:
        code = distCodes[i]
        if code != null:
            distTree = Huffman.put(distTree,code,i)    
    // done
    return (litTree,distTree,reader)

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
                    l,reader = BitBuffer.read(reader,7)
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
        j = lengthCodeMap[i]
        while |codeLengths| <= j:
            codeLengths = codeLengths + [0]
        codeLengths[j] = clen
    // second, expand code lengths to form huffman codes
    codes = Huffman.generate(codeLengths)
    // third, construct bitinary tree, whilst remembering that the codes
    // are not stored in the obvious manner.
    tree = Huffman.Empty()
    for i in 0..|codes|:
        code = codes[i]
        if code != null:
            tree = Huffman.put(tree,code,i)
    // done
    return tree,reader

