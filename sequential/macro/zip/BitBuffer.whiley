import * from whiley.lang.System

define Reader as {
    int index,  // index of current byte in data
    int boff,    // bit offset in current byte
    [byte] data 
}

public Reader Reader([byte] data):
    return {
        index: 0,
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
        reader.index = reader.index + 1
    else:
        reader.boff = boff
    // return the bit we've read
    return b == 00000001b,reader


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
    
void ::main(System sys, [string] args):
    writer = Writer()
    writer = write(writer,true)
    writer = write(writer,false)
    writer = write(writer,true)
    writer = write(writer,true)
    reader = Reader(writer.data)
    b,reader = read(reader)
    sys.out.println(b)
    b,reader = read(reader)
    sys.out.println(b)
    b,reader = read(reader)
    sys.out.println(b)
    b,reader = read(reader)
    sys.out.println(b)
    b,reader = read(reader)
    sys.out.println(b)
    b,reader = read(reader)
    sys.out.println(b)
    
