package imagelib.gif

import whiley.lang.*

define Reader as {
    int index,  // index of current byte in data
    int end,    // current end of block
    int boff,    // bit offset in current byte
    [byte] data 
}

public Reader Reader([byte] data, int start):
    end = Byte.toUnsignedInt(data[start])
    return {
        index: start+1,
        end: start+1+end,
        boff: 0,
        data: data
    }

public (bool,Reader) read(Reader reader):
    boff = reader.boff
    // first, read the current bit
    b = reader.data[reader.index]
    b = b >> boff
    b = b & 00000001b
    // now, move position to next bit
    boff = boff + 1
    if boff == 8:
        reader.boff = 0
        index = reader.index + 1
        if index == reader.end:
            // need to roll over to next block
            end = Byte.toUnsignedInt(reader.data[index])
            index = index + 1
            reader.end = index + end
         reader.index = index
    else:
        reader.boff = boff
    // return the bit we've read
    return b == 00000001b,reader

public (byte,Reader) read(Reader reader, int nbits) requires nbits >= 0 && nbits < 8:
    mask = 00000001b
    r = 0b
    for i in 0..nbits:
        bit,reader = read(reader)
        if bit:
            r = r | mask
        mask = mask << 1
    return r,reader

public (int,Reader) readUnsignedInt(Reader reader, int nbits):
    base = 1
    r = 0
    for i in 0..nbits:
        bit,reader = read(reader)
        if bit:
            r = r + base
        base = base * 2
    return r,reader



define Writer as {
    int index,  // index of current byte in data
    int boff,    // bit offset in current byte
    [byte] data 
}

public Writer Writer():
    return {
        index: 0,
        boff: 0,
        data: []
    }

public Writer write(Writer writer, bool bit):
    // first, check there's enough space
    index = writer.index
    boff = writer.boff
    if index >= |writer.data|:
        writer.data = writer.data + [00000000b]
    // second, write the bit out
    if bit:
        mask = 00000001b << boff
        writer.data[index] = writer.data[index] | mask
    // third, update offsets
    boff = boff + 1
    if boff == 8:
        writer.boff = 0
        writer.index = writer.index + 1
    else:
        writer.boff = boff
    // done!
    return writer