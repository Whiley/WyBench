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
    typeIndex = be2uint(data[pos+2..pos+4])
    superIndex = be2uint(data[pos+4..pos+6])
    print str(classItem(typeIndex,pool))
    return { 
      minor_version: be2uint(data[4..6]),
      major_version: be2uint(data[6..8]),
      type: classItem(typeIndex,pool)
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
    

