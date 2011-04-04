define FormatError as {string msg}

define ReaderState as {
    [byte] bytes,
    [int] items,
    [Constant] pool
}

ClassFile readClassFile([byte] data) throws FormatError:
    if be2uint(data[0..4]) != 0xCAFEBABE:
        throw {msg: "bad magic number"}
    pool,pos = readConstantPool(data)
    // class and super type
    typeIndex = be2uint(data[pos+2..pos+4])
    superIndex = be2uint(data[pos+4..pos+6])
    // number of interfaces
    interfaces,pos = readInterfaces(pos+6,data,pool)
    // return data
    return { 
      minor_version: be2uint(data[4..6]),
      major_version: be2uint(data[6..8]),
      modifiers:     readClassModifiers(data[pos..pos+2]),
      type:          classItem(typeIndex,pool),
      super:         classItem(superIndex,pool),
      interfaces:    interfaces
    }

([ConstantItem],int) readConstantPool([byte] data):
    nitems = be2uint(data[8..10])
    pool = [
        // We initialise the first item of the constant pool with a 
        // dummy.  This is because pool indices start from 1, not 0.  
        // Therefore, to avoid subtracting 1 from every index we just set
        // the first as a dummy.
        { tag: CONSTANT_Integer, value: 0 }
    ]
    i=1
    pos = 10
    while i < nitems:
        item,pos = constItem(data,pos)
        pool = pool + [item]
        i = i + 1
    return pool,pos            

(ConstantItem,int) constItem([byte] data, int pos) throws FormatError:
    // first, setup some useful offsets
    pos_1 = pos+1 
    pos_3 = pos+3
    pos_5 = pos+5
    // now, deal with what we've got    
    tag = data[pos]
    switch tag:        
        case CONSTANT_String:            
            si = be2uint(data[pos_1..pos_3])
            item = {
                tag: tag,
                string_index: si
            }
            pos = pos + 3
            break
        case CONSTANT_Integer:
            item = {
                tag: tag,
                // FIXME: should be be2uint
                value: be2uint(data[pos_1..pos_5])
            }
            pos = pos + 5
            break
        case CONSTANT_Long:
            item = {
                tag: tag,
                // FIXME: should be be2uint
                value: be2uint(data[pos_1..pos+9])
            }
            pos = pos + 9
            break
        case CONSTANT_Class:
            ni = be2uint(data[pos_1..pos_3])
            item = {
                tag: tag,
                name_index: ni
            }
            pos = pos + 3
            break
        case CONSTANT_FieldRef:
        case CONSTANT_MethodRef:
        case CONSTANT_InterfaceMethodRef:
            ci = be2uint(data[pos_1..pos_3])
            nti = be2uint(data[pos_3..pos_5])
            item = {
                tag: tag,
                class_index: ci,
                name_and_type_index: nti
            }
            pos = pos + 5
            break
        case CONSTANT_NameAndType:
            ni = be2uint(data[pos_1..pos_3])
            di = be2uint(data[pos_3..pos_5])
            item = {
                tag: tag,
                name_index: ni,
                descriptor_index: di
            }
            pos = pos + 5
            break
        case CONSTANT_Utf8:
            len = be2uint(data[pos_1..pos_3])
            item = {
                tag: tag,
                // FIXME: should really decode here
                value: data[pos_3..pos_3+len]
            }
            pos = pos_3+len
            break
        default:
            throw {msg: "invalid constant pool item"}
    // ok, finally return the item
    return (item,pos)

{ClassModifier} readClassModifiers([byte] bytes):
    // This method is not the best way to do this.  When Whiley 
    // gets proper support for bit vectors, we'll be able to do better.
    mods = be2uint(bytes)    
    r = {}
    base = 32768
    while mods > 0:
        if mods >= base:
            mods = mods - base
            r = r + {base}
        base = base / 2
    return r        

([class_t],int) readInterfaces(int pos, [byte] data, [ConstantItem] pool):
    num = be2uint(data[pos..pos+2])    
    i = 0
    pos = pos + 2
    r = []
    while i < num:
        idx = be2uint(data[pos..pos+2])
        r = r + [classItem(idx,pool)]
        pos = pos + 2
        i = i + 1
    return r,pos
