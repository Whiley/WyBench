define Constant as string | int | real 

define CONSTANT_Utf8 as 1
define CONSTANT_Integer as 3
define CONSTANT_Float as 4
define CONSTANT_Long as 5
define CONSTANT_Double as 6
define CONSTANT_Class as 7
define CONSTANT_String as 8
define CONSTANT_FieldRef as 9
define CONSTANT_MethodRef as 10
define CONSTANT_InterfaceMethodRef as 11
define CONSTANT_NameAndType as 12


define StringInfo as {
    uint8 tag,
    uint16 string_index
}

define ClassInfo as {
    uint8 tag,
    uint16 name_index
}

define Utf8Info as {
    uint8 tag,
    [byte] value        
}

define IntegerInfo as {
    uint8 tag,
    int32 value        
}

define LongInfo as {
    uint8 tag,
    int64 value        
}

define FieldRefInfo as { 
    uint8 tag,
    uint16 class_index,
    uint16 name_and_type_index
}

define MethodRefInfo as { 
    uint8 tag,
    uint16 class_index,
    uint16 name_and_type_index
}

define InterfaceMethodRefInfo as { 
    uint8 tag,
    uint16 class_index,
    uint16 name_and_type_index
}

define NameAndTypeInfo as {
    uint8 tag,
    uint16 name_index,
    uint16 descriptor_index    
}

define ConstantItem as FieldRefInfo | 
        MethodRefInfo | 
        InterfaceMethodRefInfo | 
        StringInfo | 
        ClassInfo |
        Utf8Info |
        IntegerInfo | 
        LongInfo | 
        NameAndTypeInfo

// extract a class type item
class_t classItem(int index, [ConstantItem] pool) throws FormatError:
    item = pool[index]
    if item ~= ClassInfo:
        utf8 = utf8Item(item.name_index,pool)
        return parseClassDescriptor(utf8)
    else:
        throw {msg: "invalid class item"}

// extract a utf8 string item
string utf8Item(int index, [ConstantItem] pool) throws FormatError:
    item = pool[index]
    if item ~= Utf8Info:
        return item.value
    else:
        throw {msg: "invalid utf8 item"}

jvm_t typeItem(int index, [ConstantItem] pool) throws FormatError:
    desc = utf8Item(index,pool)
    return parseDescriptor(desc)

fun_t methodTypeItem(int index, [ConstantItem] pool) throws FormatError:
    desc = utf8Item(index,pool)
    return parseMethodDescriptor(desc)

(string,string) nameAndTypeItem(int index, [ConstantItem] pool) throws FormatError:
    item = pool[index]
    if item ~= NameAndTypeInfo:
        name = utf8Item(item.name_index,pool)
        desc = utf8Item(item.descriptor_index,pool)
        return name,desc
    else:
        throw {msg: "invalid name and type item"}                

(class_t,string,fun_t) methodRefItem(int index, [ConstantItem] pool) throws FormatError:
    item = pool[index]
    if item ~= MethodRefInfo:
        owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseMethodDescriptor(desc)
    else:
        throw {msg: "invalid method ref item"}

(class_t,string,jvm_t) fieldRefItem(int index, [ConstantItem] pool) throws FormatError:
    item = pool[index]
    if item ~= FieldRefInfo:
        owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseDescriptor(desc)
    else:
        throw {msg: "invalid field ref item"}

jvm_t parseDescriptor(string desc):
    type,pos = parseDescriptor(0,desc)
    return type

class_t parseClassDescriptor(string desc):    
    desc = replace('/','.',desc)
    idx = lastIndexOf('.',desc)
    if idx ~= null:
        pkg = ""
        name = desc
    else:
        pkg = desc[0..idx]
        name = desc[idx+1..|desc|]
    // FIXME: split out inner classes here.
    return {pkg: pkg, classes:[name]}

(jvm_t,int) parseDescriptor(int pos, string desc) throws FormatError:
    if pos >= |desc|:
        throw {msg: "invalid descriptor"}
    lookahead = desc[pos]
    switch lookahead:
        case 'B':
            return T_BOOLEAN,pos+1
        case 'C':
            return T_CHAR,pos+1
        case 'D':
            return T_DOUBLE,pos+1
        case 'F':
            return T_FLOAT,pos+1
        case 'I':
            return T_INT,pos+1
        case 'J':
            return T_LONG,pos+1
        case 'S':
            return T_SHORT,pos+1
        case 'Z':
            return T_BOOLEAN,pos+1
        case 'V':
            return T_VOID,pos+1
        case 'L':
            end = indexOf(';',pos+1,desc)
            if end ~= null:
                throw {msg: "invalid descriptor"}
            type = parseClassDescriptor(desc[pos+1..end])
            return type,end+1
        case '[':
            elem,pos = parseDescriptor(pos+1,desc)
            return T_ARRAY(elem),pos
    // unknown cases
    throw {msg: "invalid descriptor"}

fun_t parseMethodDescriptor(string desc) throws FormatError:
    if desc[0] != '(':
        throw { msg: "invalid method descriptor" }
    pos = 1
    params = []
    while desc[pos] != ')':
        param,pos = parseDescriptor(pos,desc)
        params = params + [param]
    ret,pos = parseDescriptor(pos+1,desc)
    return { ret: ret, params: params }
