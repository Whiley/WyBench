import whiley.lang.*

import * from ClassFile
import * from ConstantPool
import * from Bytecodes

define FormatError as {string msg}

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
    Type.uint8 tag,
    Type.uint16 string_index
}

define ClassInfo as {
    Type.uint8 tag,
    Type.uint16 name_index
}

define Utf8Info as {
    Type.uint8 tag,
    [byte] value        
}

define IntegerInfo as {
    Type.uint8 tag,
    Type.int32 value        
}

define LongInfo as {
    Type.uint8 tag,
    Type.int64 value        
}

define FieldRefInfo as { 
    Type.uint8 tag,
    Type.uint16 class_index,
    Type.uint16 name_and_type_index
}

define MethodRefInfo as { 
    Type.uint8 tag,
    Type.uint16 class_index,
    Type.uint16 name_and_type_index
}

define InterfaceMethodRefInfo as { 
    Type.uint8 tag,
    Type.uint16 class_index,
    Type.uint16 name_and_type_index
}

define NameAndTypeInfo as {
    Type.uint8 tag,
    Type.uint16 name_index,
    Type.uint16 descriptor_index    
}

define Item as FieldRefInfo | 
        MethodRefInfo | 
        InterfaceMethodRefInfo | 
        StringInfo | 
        ClassInfo |
        Utf8Info |
        IntegerInfo | 
        LongInfo | 
        NameAndTypeInfo

int integerItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is IntegerInfo:
        return item.value
    else:
        throw {msg: "invalid integer item"}

int longItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is LongInfo:
        return item.value
    else:
        throw {msg: "invalid integer item"}

// extract a utf8 string item
string utf8Item(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is Utf8Info:
        return String.fromASCII(item.value)
    else:
        throw {msg: "invalid utf8 item"}

string stringItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is StringInfo:
        return utf8Item(item.string_index,pool)
    else:
        throw {msg: "invalid string item"}

// extract a class type item
JvmType.Class classItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is ClassInfo:
        utf8 = utf8Item(item.name_index,pool)
        return parseClassDescriptor(utf8)
    else:
        throw {msg: "invalid class item"}

JvmType.Any typeItem(int index, [Item] pool) throws FormatError:
    desc = utf8Item(index,pool)
    return parseDescriptor(desc)

JvmType.Fun methodTypeItem(int index, [Item] pool) throws FormatError:
    desc = utf8Item(index,pool)
    return parseMethodDescriptor(desc)

(string,string) nameAndTypeItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is NameAndTypeInfo:
        name = utf8Item(item.name_index,pool)
        desc = utf8Item(item.descriptor_index,pool)
        return name,desc
    else:
        throw {msg: "invalid name and type item"}                

(JvmType.Class,string,JvmType.Fun) methodRefItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is MethodRefInfo:
        owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseMethodDescriptor(desc)
    else:
        throw {msg: "invalid method ref item"}

(JvmType.Class,string,JvmType.Any) fieldRefItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is FieldRefInfo:
        owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseDescriptor(desc)
    else:
        throw {msg: "invalid field ref item"}

Constant numberOrStringItem(int index, [Item] pool) throws FormatError:
    item = pool[index]
    if item is StringInfo:
        return stringItem(index,pool)
    else if item is IntegerInfo:
        return integerItem(index,pool)
    //    else if item is LongInfo:
    //        return longItem(index,pool)
    else:
        return -1 // quick hack

JvmType.Any parseDescriptor(string desc):
    type,pos = parseDescriptor(0,desc)
    return type

JvmType.Class parseClassDescriptor(string desc):    
    desc = String.replace('/','.',desc)
    idx = String.lastIndexOf('.',desc)
    if idx is null:
        pkg = ""
        name = desc
    else:
        pkg = desc[0..idx]
        name = desc[idx+1..|desc|]
    // FIXME: split out inner classes here.
    return {pkg: pkg, classes:[name]}

(JvmType.Any,int) parseDescriptor(int pos, string desc) throws FormatError:
    if pos >= |desc|:
        throw {msg: "invalid descriptor"}
    lookahead = desc[pos]
    switch lookahead:
        case 'B':
            return JvmType.Boolean,pos+1
        case 'C':
            return JvmType.Char,pos+1
        case 'D':
            return JvmType.Double,pos+1
        case 'F':
            return JvmType.Float,pos+1
        case 'I':
            return JvmType.Int,pos+1
        case 'J':
            return JvmType.Long,pos+1
        case 'S':
            return JvmType.Short,pos+1
        case 'Z':
            return JvmType.Boolean,pos+1
        case 'V':
            return JvmType.Void,pos+1
        case 'L':
            end = String.indexOf(';',pos+1,desc)
            if end is null:
                throw {msg: "invalid descriptor"}
            type = parseClassDescriptor(desc[pos+1..end])
            return type,end+1
        case '[':
            elem,pos = parseDescriptor(pos+1,desc)
            return JvmType.Array(elem),pos
    // unknown cases
    throw {msg: "invalid descriptor"}

JvmType.Fun parseMethodDescriptor(string desc) throws FormatError:
    if desc[0] != '(':
        throw { msg: "invalid method descriptor" }
    pos = 1
    params = []
    while desc[pos] != ')':
        param,pos = parseDescriptor(pos,desc)
        params = params + [param]
    ret,pos = parseDescriptor(pos+1,desc)
    return { ret: ret, params: params }
