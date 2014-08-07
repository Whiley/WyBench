import whiley.lang.*
import Error from whiley.lang.Errors

import * from ClassFile
import * from ConstantPool
import * from Bytecodes

// ============================================================
// Definitions
// ============================================================

public type Constant is string | int | real 

public constant CONSTANT_Utf8 is 1
public constant CONSTANT_Integer is 3
public constant CONSTANT_Float is 4
public constant CONSTANT_Long is 5
public constant CONSTANT_Double is 6
public constant CONSTANT_Class is 7
public constant CONSTANT_String is 8
public constant CONSTANT_FieldRef is 9
public constant CONSTANT_MethodRef is 10
public constant CONSTANT_InterfaceMethodRef is 11
public constant CONSTANT_NameAndType is 12

public type StringInfo is {
    Int.u8 tag,
    Int.u16 string_index
}

public type ClassInfo is {
    Int.u8 tag,
    Int.u16 name_index
}

public type Utf8Info is {
    Int.u8 tag,
    [byte] value        
}

public type IntegerInfo is {
    Int.u8 tag,
    Int.i32 value        
}

public type LongInfo is {
    Int.u8 tag,
    Int.i64 value        
}

public type FieldRefInfo is { 
    Int.u8 tag,
    Int.u16 class_index,
    Int.u16 name_and_type_index
}

public type MethodRefInfo is { 
    Int.u8 tag,
    Int.u16 class_index,
    Int.u16 name_and_type_index
}

public type InterfaceMethodRefInfo is { 
    Int.u8 tag,
    Int.u16 class_index,
    Int.u16 name_and_type_index
}

public type NameAndTypeInfo is {
    Int.u8 tag,
    Int.u16 name_index,
    Int.u16 descriptor_index    
}

public type Item is FieldRefInfo | 
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

public function integerItem(int index, [Item] pool) => int
throws Error:
    Item item = pool[index]
    if item is IntegerInfo:
        return item.value
    else:
        throw {msg: "invalid integer item"}

public function longItem(int index, [Item] pool) => int
throws Error:
    Item item = pool[index]
    if item is LongInfo:
        return item.value
    else:
        throw {msg: "invalid integer item"}

// extract a utf8 string item
public function utf8Item(int index, [Item] pool) => string 
throws Error:
    Item item = pool[index]
    if item is Utf8Info:
        return String.fromASCII(item.value)
    else:
        throw {msg: "invalid utf8 item"}

public function stringItem(int index, [Item] pool) => string
throws Error:
    Item item = pool[index]
    if item is StringInfo:
        return utf8Item(item.string_index,pool)
    else:
        throw {msg: "invalid string item"}

// extract a class type item
public function classItem(int index, [Item] pool) => JvmType.Class
throws Error:
    Item item = pool[index]
    if item is ClassInfo:
        string utf8 = utf8Item(item.name_index,pool)
        return parseClassDescriptor(utf8)
    else:
        throw {msg: "invalid class item"}

public function typeItem(int index, [Item] pool) => JvmType.Any
throws Error:
    string desc = utf8Item(index,pool)
    return parseDescriptor(desc)

public function methodTypeItem(int index, [Item] pool) => JvmType.Fun
throws Error:
    string desc = utf8Item(index,pool)
    return parseMethodDescriptor(desc)

public function nameAndTypeItem(int index, [Item] pool) => (string,string)
throws Error:
    Item item = pool[index]
    if item is NameAndTypeInfo:
        string name = utf8Item(item.name_index,pool)
        string desc = utf8Item(item.descriptor_index,pool)
        return name,desc
    else:
        throw {msg: "invalid name and type item"}                

public function methodRefItem(int index, [Item] pool) => (JvmType.Class,string,JvmType.Fun)
throws Error:    
    Item item = pool[index]
    //
    if item is MethodRefInfo:
        string name
        string desc
        JvmType.Class owner = classItem(item.class_index,pool)
        name, desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseMethodDescriptor(desc)
    else:
        throw {msg: "invalid method ref item"}

public function fieldRefItem(int index, [Item] pool) => (JvmType.Class,string,JvmType.Any) 
throws Error:
    Item item = pool[index]
    if item is FieldRefInfo:
        string name
        string desc
        JvmType.Class owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseDescriptor(desc)
    else:
        throw {msg: "invalid field ref item"}

public function numberOrStringItem(int index, [Item] pool) => Constant
throws Error:
    Item item = pool[index]
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

type Utf8Tree is {
    Int.u8 tag,
    [byte] value        
}

type IntegerTree is {
    Int.u8 tag,
    Int.i32 value        
}

type LongTree is {
    Int.u8 tag,
    Int.i64 value        
}

type StringTree is {
    Int.u8 tag,
    Utf8Tree string_index
}

type ClassTree is {
    Int.u8 tag,
    Utf8Tree name_index
}

type NameAndTypeTree is {
    Int.u8 tag,
    Utf8Tree name_index,
    Utf8Tree descriptor_index    
}

type FieldRefTree is { 
    Int.u8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

type MethodRefTree is { 
    Int.u8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

type InterfaceMethodRefTree is { 
    Int.u8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

type Tree is FieldRefTree | 
        MethodRefTree | 
        InterfaceMethodRefTree | 
        StringTree | 
        ClassTree |
        Utf8Tree |
        IntegerTree | 
        LongTree | 
        NameAndTypeTree

public type Index is {Tree=>int}

public function Utf8Tree(string utf8) => Utf8Tree:
    [byte] bytes = String.toUTF8(utf8)
    return {
        tag: CONSTANT_Utf8,
        value: bytes
    }

public function ClassTree(JvmType.Class c) => ClassTree:
    return {
        tag: CONSTANT_Class,
        name_index: Utf8Tree(classDescriptor(c))
    }

public function add([Item] pool, Index index, Tree item) => ([Item],Index):
    int i
    pool,index,i = addHelper(pool,index,item)
    return pool,index

function addHelper([Item] pool, Index index, Tree item) => ([Item],Index,int):
    // first, check if already allocated in pool
    int|null i = lookup(index,item)
    if i != null:
        return pool,index,i
    // second, recursively allocate item
    if item is Utf8Tree:
        index[item] = |pool|
        pool = pool ++ [item]
    else if item is StringTree:        
        pool,index,i = addHelper(pool,index,item.string_index)
        index[item] = |pool|
        StringInfo info = {tag: item.tag, string_index: i}
        pool = pool ++ [info]
    else if item is ClassTree:
        pool,index,i = addHelper(pool,index,item.name_index)
        index[item] = |pool|
        ClassInfo info = {tag: item.tag, name_index: i}
        pool = pool ++ [info]
    // finally, done!
    return pool,index,|pool|-1

// the following method is a temporary hack
function lookup(Index index, Tree item) => int|null:
    for k,v in index:
        if k == item:
            return v
    return null

// ============================================================
// Parse Descriptors
// ============================================================

function parseDescriptor(string desc) => JvmType.Any
throws Error:
    JvmType.Any type
    int pos
    type,pos = parseDescriptor(0,desc)
    return type

function parseClassDescriptor(string desc) => JvmType.Class:    
    desc = String.replace(desc,'/','.')
    int|null idx = String.lastIndexOf(desc,'.')
    string pkg
    string name
    if idx is null:
        pkg = ""
        name = desc
    else:
        pkg = desc[0..idx]
        name = desc[idx+1..|desc|]
    // FIXME: split out inner classes here.
    return {pkg: pkg, classes:[name]}

function parseDescriptor(int pos, string desc) => (JvmType.Any,int)
throws Error:
    if pos >= |desc|:
        throw {msg: "invalid descriptor"}
    char lookahead = desc[pos]
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
            int|null end = String.indexOf(desc,';',pos+1)
            if end is null:
                throw {msg: "invalid descriptor"}
            JvmType.Class type = parseClassDescriptor(desc[pos+1..end])
            return type,end+1
        case '[':
            JvmType.Any elem
            elem,pos = parseDescriptor(pos+1,desc)
            return JvmType.Array(elem),pos
    // unknown cases
    throw {msg: "invalid descriptor"}

function parseMethodDescriptor(string desc) => JvmType.Fun
throws Error:
    if desc[0] != '(':
        throw { msg: "invalid method descriptor" }
    JvmType.Any param
    JvmType.Any ret
    int pos = 1
    [JvmType.Any] params = []
    while desc[pos] != ')':
        param,pos = parseDescriptor(pos,desc)
        params = params ++ [param]
    //
    ret,pos = parseDescriptor(pos+1,desc)
    return { ret: ret, params: params }

// ============================================================
// Write Descriptors
// ============================================================

function descriptor(JvmType.Any t) => string:
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
        return "[" ++ descriptor(t.element)
    else if t is JvmType.Class:
        return "L" ++ classDescriptor(t) ++ ";"
    else:
        return "" // deadcode

function descriptor(JvmType.Fun t) => string:
    string desc = "("
    for p in t.params:
        desc = desc ++ descriptor(p)
    return desc ++ ")" ++ descriptor(t.ret)

function classDescriptor(JvmType.Class ct) => string:
    string pkg = String.replace(ct.pkg,'.','/')
    bool firstTime
    if pkg == "":
        firstTime=true
    else:
        firstTime=false
    string classes = ""
    // now add class components
    for class in ct.classes:
        if !firstTime:
            classes = classes ++ "/"
        firstTime=false
        classes = classes ++ class
    // done
    return pkg ++ classes
