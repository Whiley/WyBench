define FormatError as {string msg}

define ReaderState as {
    [byte] bytes,
    [int] items,
    [Constant] pool
}

ClassFile|FormatError readClassFile([byte] data):
    if be2uint(data[0..4]) != 0xCAFEBABE:
        return {msg: "bad magic number"}
    nitems = le2uint(data[8..10])
    print "NITEMS: " + str(nitems)
    pool = [null] // first item is dummy
    i=0
    pos = 0
    while i < nitems:
        item,pos = constItem(data,pos)
        pool = pool + [item]
        i = i + 1
    return { 
      minor_version: le2uint(data[4..6]),
      major_version: le2uint(data[6..8]) 
    }

(CONSTANT_Item,int) constItem([byte] data, int pos):
    // could do with a switch statement here
    tag = data[pos]
    if tag == CONSTANT_FieldRef:
        
    else if tag == CONSTANT_MethodRef:

    else if tag == CONSTANT_InterfaceMethodRef:

    else if tag == CONSTANT_String:
    

