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
