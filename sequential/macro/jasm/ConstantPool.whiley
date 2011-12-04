import whiley.lang.*
import Error from whiley.lang.Errors

import * from ClassFile
import * from ConstantPool
import * from Bytecodes

// ============================================================
// Definitions
// ============================================================

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

// ============================================================
// Decoding Functions
// ============================================================

int integerItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is IntegerInfo:
        return item.value
    else:
        throw {msg: "invalid integer item"}

int longItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is LongInfo:
        return item.value
    else:
        throw {msg: "invalid integer item"}

// extract a utf8 string item
string utf8Item(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is Utf8Info:
        return String.fromASCII(item.value)
    else:
        throw {msg: "invalid utf8 item"}

string stringItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is StringInfo:
        return utf8Item(item.string_index,pool)
    else:
        throw {msg: "invalid string item"}

// extract a class type item
JvmType.Class classItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is ClassInfo:
        utf8 = utf8Item(item.name_index,pool)
        return parseClassDescriptor(utf8)
    else:
        throw {msg: "invalid class item"}

JvmType.Any typeItem(int index, [Item] pool) throws Error:
    desc = utf8Item(index,pool)
    return parseDescriptor(desc)

JvmType.Fun methodTypeItem(int index, [Item] pool) throws Error:
    desc = utf8Item(index,pool)
    return parseMethodDescriptor(desc)

(string,string) nameAndTypeItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is NameAndTypeInfo:
        name = utf8Item(item.name_index,pool)
        desc = utf8Item(item.descriptor_index,pool)
        return name,desc
    else:
        throw {msg: "invalid name and type item"}                

(JvmType.Class,string,JvmType.Fun) methodRefItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is MethodRefInfo:
        owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseMethodDescriptor(desc)
    else:
        throw {msg: "invalid method ref item"}

(JvmType.Class,string,JvmType.Any) fieldRefItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is FieldRefInfo:
        owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseDescriptor(desc)
    else:
        throw {msg: "invalid field ref item"}

Constant numberOrStringItem(int index, [Item] pool) throws Error:
    item = pool[index]
    if item is StringInfo:
        return stringItem(index,pool)
    else if item is IntegerInfo:
        return integerItem(index,pool)
    //    else if item is LongInfo:
    //        return longItem(index,pool)
    else:
        return -1 // quick hack

// ============================================================
// Encoding Functions
// ============================================================

define Utf8Tree as {
    Type.uint8 tag,
    [byte] value        
}

define IntegerTree as {
    Type.uint8 tag,
    Type.int32 value        
}

define LongTree as {
    Type.uint8 tag,
    Type.int64 value        
}

define StringTree as {
    Type.uint8 tag,
    Utf8Tree string_index
}

define ClassTree as {
    Type.uint8 tag,
    Utf8Tree name_index
}

define NameAndTypeTree as {
    Type.uint8 tag,
    Utf8Tree name_index,
    Utf8Tree descriptor_index    
}

define FieldRefTree as { 
    Type.uint8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

define MethodRefTree as { 
    Type.uint8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

define InterfaceMethodRefTree as { 
    Type.uint8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

define Tree as FieldRefTree | 
        MethodRefTree | 
        InterfaceMethodRefTree | 
        StringTree | 
        ClassTree |
        Utf8Tree |
        IntegerTree | 
        LongTree | 
        NameAndTypeTree

public define Index as {Tree->int}

public Utf8Tree Utf8Tree(string utf8):
    bytes = String.toUTF8(utf8)
    return {
        tag: CONSTANT_Utf8,
        value: bytes
    }

public ClassTree ClassTree(JvmType.Class c):
    return {
        tag: CONSTANT_Class,
        name_index: Utf8Tree(classDescriptor(c))
    }

public ([Item],Index) add([Item] pool, Index index, Tree item):
    pool,index,i = addHelper(pool,index,item)
    return pool,index

([Item],Index,int) addHelper([Item] pool, Index index, Tree item):
    // first, check if already allocated in pool
    i = lookup(index,item)
    if i != null:
        return pool,index,i
    // second, recursively allocate item
    if item is Utf8Tree:
        index[item] = |pool|
        pool = pool + [item]
    else if item is StringTree:        
        pool,index,i = addHelper(pool,index,item.string_index)
        index[item] = |pool|
        item.string_index = i
        pool = pool + [item]
    else if item is ClassTree:
        pool,index,i = addHelper(pool,index,item.name_index)
        index[item] = |pool|
        item.name_index = i
        pool = pool + [item]
    // finally, done!
    return pool,index,|pool|-1

// the following method is a temporary hack
int|null lookup(Index index, Tree item):
    for k,v in index:
        if k == item:
            return v
    return null

// ============================================================
// Parse Descriptors
// ============================================================

JvmType.Any parseDescriptor(string desc) throws Error:
    type,pos = parseDescriptor(0,desc)
    return type

JvmType.Class parseClassDescriptor(string desc):    
    desc = String.replace(desc,'/','.')
    idx = String.lastIndexOf(desc,'.')
    if idx is null:
        pkg = ""
        name = desc
    else:
        pkg = desc[0..idx]
        name = desc[idx+1..|desc|]
    // FIXME: split out inner classes here.
    return {pkg: pkg, classes:[name]}

(JvmType.Any,int) parseDescriptor(int pos, string desc) throws Error:
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
            end = String.indexOf(desc,';',pos+1)
            if end is null:
                throw {msg: "invalid descriptor"}
            type = parseClassDescriptor(desc[pos+1..end])
            return type,end+1
        case '[':
            elem,pos = parseDescriptor(pos+1,desc)
            return JvmType.Array(elem),pos
    // unknown cases
    throw {msg: "invalid descriptor"}

JvmType.Fun parseMethodDescriptor(string desc) throws Error:
    if desc[0] != '(':
        throw { msg: "invalid method descriptor" }
    pos = 1
    params = []
    while desc[pos] != ')':
        param,pos = parseDescriptor(pos,desc)
        params = params + [param]
    ret,pos = parseDescriptor(pos+1,desc)
    return { ret: ret, params: params }

// ============================================================
// Write Descriptors
// ============================================================

string descriptor(JvmType.Any t):
    if t is JvmType.Primitive:
        switch t:
            case JvmType.Void:
                return "D"
            case JvmType.Boolean:
                return "Z"
            case JvmType.Byte:
                return "B"
            case JvmType.Char:
                return "C"
            case JvmType.Short:
                return "S"
            case JvmType.Int:
                return "I"
            case JvmType.Long:
                return "J"
            case JvmType.Float:
                return "F"
            default:
                return "D"
    else if t is JvmType.Array:
        return "[" + descriptor(t.element)
    else: 
        // t is JvmType.Class:
        return "L" + classDescriptor(t) + ";"

string descriptor(JvmType.Fun t):
    desc = "("
    for p in t.params:
        desc = desc + descriptor(p)
    return desc + ")" + descriptor(t.ret)

string classDescriptor(JvmType.Class ct):
    pkg = String.replace(ct.pkg,'.','/')
    if pkg == "":
        firstTime=true
    else:
        firstTime=false
    classes = ""
    // now add class components
    for class in ct.classes:
        if !firstTime:
            classes = classes + "/"
        firstTime=false
        classes = classes + class
    // done
    return pkg + classes
