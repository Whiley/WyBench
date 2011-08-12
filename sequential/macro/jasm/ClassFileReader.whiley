define FormatError as {string msg}

define ReaderState as {
    [byte] bytes,
    [int] items,
    [Constant] pool
}

ClassFile readClassFile([byte] data) throws FormatError:
    if uint(data[4..0]) != 0xCAFEBABE:
        throw {msg: "bad magic number"}
    pool,pend = readConstantPool(data)
    // class and super type
    typeIndex = uint(data[pend+4..pend+2])
    superIndex = uint(data[pend+6..pend+4])
    // read interfaces
    interfaces,pos = readInterfaces(pend+6,data,pool)
    // read fields
    fields,pos = readFields(pos,data,pool)
    // read methods
    methods,pos = readMethods(pos,data,pool)
    // read attributes
    attrs,pos = readAttributes(pos,data,pool)
    // return data
    return { 
      minor_version: uint(data[6..4]),
      major_version: uint(data[8..6]),
      modifiers:     readClassModifiers(data[pend+2..pend]),
      type:          classItem(typeIndex,pool),
      super:         classItem(superIndex,pool),
      interfaces:    interfaces,
      fields: fields,
      methods: methods
    }

([ConstantItem],int) readConstantPool([byte] data):
    nitems = uint(data[10..8])
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
        if item.tag == CONSTANT_Long || item.tag == CONSTANT_Double:
            // For some reason, longs and doubles take two slots.
            // So, we put a "dummy" into the second slot.
            pool = pool + [{tag: CONSTANT_Integer, value: 0}]
            i = i + 2
        else:
            i = i + 1
    return pool,pos            

(ConstantItem,int) constItem([byte] data, int pos) throws FormatError:
    // first, setup some useful offsets
    pos_1 = pos+1 
    pos_3 = pos+3
    pos_5 = pos+5
    // now, deal with what we've got    
    tag = uint(data[pos])
    switch tag:        
        case CONSTANT_String:            
            si = uint(data[pos_3..pos_1])
            item = {
                tag: tag,
                string_index: si
            }
            pos = pos + 3
            break
        case CONSTANT_Float:
        case CONSTANT_Integer:
            item = {
                tag: tag,
                value: uint(data[pos_5..pos_1])
            }
            pos = pos + 5
            break
        case CONSTANT_Double:
        case CONSTANT_Long:
            item = {
                tag: tag,
                value: uint(data[pos+9..pos_1])
            }
            pos = pos + 9
            break
        case CONSTANT_Class:
            ni = uint(data[pos_3..pos_1])
            item = {
                tag: tag,
                name_index: ni
            }
            pos = pos + 3
            break
        case CONSTANT_FieldRef:
        case CONSTANT_MethodRef:
        case CONSTANT_InterfaceMethodRef:
            ci = uint(data[pos_3..pos_1])
            nti = uint(data[pos_5..pos_3])
            item = {
                tag: tag,
                class_index: ci,
                name_and_type_index: nti
            }
            pos = pos + 5
            break
        case CONSTANT_NameAndType:
            ni = uint(data[pos_3..pos_1])
            di = uint(data[pos_5..pos_3])
            item = {
                tag: tag,
                name_index: ni,
                descriptor_index: di
            }
            pos = pos + 5
            break
        case CONSTANT_Utf8:
            len = uint(data[pos_3..pos_1])
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
    mods = uint(bytes[|bytes|..0])    
    r = {}
    base = 32768
    while mods > 0:
        if mods >= base:
            mods = mods - base
            r = r + {base}
        base = base / 2
    return r        

([class_t],int) readInterfaces(int pos, [byte] data, [ConstantItem] pool):
    num = uint(data[pos+2..pos])    
    i = 0
    pos = pos + 2
    r = []
    while i < num:
        idx = uint(data[pos+2..pos])
        r = r + [classItem(idx,pool)]
        pos = pos + 2
        i = i + 1
    return r,pos

([FieldInfo],int) readFields(int pos, [byte] data, [ConstantItem] pool):
    nfields = uint(data[pos+2..pos])
    pos = pos + 2
    fields = []
    while nfields > 0:
        f,pos = readField(pos,data,pool)
        fields = fields + [f]
        nfields = nfields - 1
    return fields,pos

([MethodInfo],int) readMethods(int pos, [byte] data, [ConstantItem] pool):
    nmethods = uint(data[pos+2..pos])
    pos = pos + 2
    methods = []
    while nmethods > 0:
        f,pos = readMethod(pos,data,pool)
        methods = methods + [f]
        nmethods = nmethods - 1
    return methods,pos

(FieldInfo,int) readField(int pos, [byte] data, [ConstantItem] pool):       
    // now, parse attributes
    attrs,end = readAttributes(pos+6,data,pool)    
    return {
        modifiers: readFieldModifiers(data[pos..pos+2]),
        name: utf8Item(uint(data[pos+4..pos+2]),pool),
        type: typeItem(uint(data[pos+6..pos+4]),pool),
        attributes: attrs
    },end

(MethodInfo,int) readMethod(int pos, [byte] data, [ConstantItem] pool):       
    // now, parse attributes
    attrs,end = readAttributes(pos+6,data,pool)    
    return {
        modifiers: readMethodModifiers(data[pos..pos+2]),
        name: utf8Item(uint(data[pos+4..pos+2]),pool),
        type: methodTypeItem(uint(data[pos+6..pos+4]),pool),
        attributes: attrs
    },end

{FieldModifier} readFieldModifiers([byte] bytes):
    // This method is not the best way to do this.  When Whiley 
    // gets proper support for bit vectors, we'll be able to do better.
    mods = uint(bytes[|bytes|..0])    
    r = {}
    base = 32768
    while mods > 0:
        if mods >= base:
            mods = mods - base
            r = r + {base}
        base = base / 2
    return r   

{MethodModifier} readMethodModifiers([byte] bytes):
    // This method is not the best way to do this.  When Whiley 
    // gets proper support for bit vectors, we'll be able to do better.
    mods = uint(bytes[|bytes|..0])    
    r = {}
    base = 32768
    while mods > 0:
        if mods >= base:
            mods = mods - base
            r = r + {base}
        base = base / 2
    return r   

([AttributeInfo],int) readAttributes(int pos, [byte] data, [ConstantItem] pool):
    nattrs = uint(data[pos+2..pos])    
    attrs = []
    i = 0
    pos = pos + 2
    while i < nattrs:
        attr,pos = readAttribute(pos,data,pool)
        attrs = attrs + [attr]
        i = i + 1
    return attrs,pos

(AttributeInfo,int) readAttribute(int pos, [byte] data, [ConstantItem] pool):
    name = utf8Item(uint(data[pos+2..pos]),pool)
    nbytes = uint(data[pos+6..pos+2])    
    end = pos + 6 + nbytes
    // TODO: replace this hard-coded dispatch with a dispatch table.
    if name == "Code":
        return readCodeAttribute(data[pos..end], pool),end
    else:
        // unknown attribute
        return {
            name: name,
            data: data[pos+6..end]
        },end
