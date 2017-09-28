import std::ascii
import u8 from std::integer
import u16 from std::integer
import i32 from std::integer
import i64 from std::integer
import util

// ============================================================
// Definitions
// ============================================================

public type Constant is string | int // | real 

public int CONSTANT_Utf8 = 1
public int CONSTANT_Integer = 3
public int CONSTANT_Float = 4
public int CONSTANT_Long = 5
public int CONSTANT_Double = 6
public int CONSTANT_Class = 7
public int CONSTANT_String = 8
public int CONSTANT_FieldRef = 9
public int CONSTANT_MethodRef = 10
public int CONSTANT_InterfaceMethodRef = 11
public int CONSTANT_NameAndType = 12

public type StringInfo is {
    u8 tag,
    u16 string_index
}

public type ClassInfo is {
    u8 tag,
    u16 name_index
}

public type Utf8Info is {
    u8 tag,
    byte[] value        
}

public type IntegerInfo is {
    u8 tag,
    i32 value        
}

public type LongInfo is {
    u8 tag,
    i64 value        
}

public type FieldRefInfo is { 
    u8 tag,
    u16 class_index,
    u16 name_and_type_index
}

public type MethodRefInfo is { 
    u8 tag,
    u16 class_index,
    u16 name_and_type_index
}

public type InterfaceMethodRefInfo is { 
    u8 tag,
    u16 class_index,
    u16 name_and_type_index
}

public type NameAndTypeInfo is {
    u8 tag,
    u16 name_index,
    u16 descriptor_index    
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

public function integerItem(int index, Item[] pool) -> int|null:
    Item item = pool[index]
    if item is IntegerInfo:
        return item.value
    else:
        return null

public function longItem(int index, Item[] pool) -> int|null:
    Item item = pool[index]
    if item is LongInfo:
        return item.value
    else:
        return null

// extract a utf8 string item
public function utf8Item(int index, Item[] pool) -> string|null:
    Item item = pool[index]
    if item is Utf8Info:
        return String.fromASCII(item.value)
    else:
        return null

public function stringItem(int index, Item[] pool) -> string|null:
    Item item = pool[index]
    if item is StringInfo:
        return utf8Item(item.string_index,pool)
    else:
        return null

// extract a class type item
public function classItem(int index, Item[] pool) -> JvmType::Class|null:
    Item item = pool[index]
    if item is ClassInfo:
        string utf8 = utf8Item(item.name_index,pool)
        return parseClassDescriptor(utf8)
    else:
        return null

public function typeItem(int index, Item[] pool) -> JvmType::Any|null:
    string desc = utf8Item(index,pool)
    return parseDescriptor(desc)

public function methodTypeItem(int index, Item[] pool) -> JvmType::Fun|null:
    string desc = utf8Item(index,pool)
    return parseMethodDescriptor(desc)

public function nameAndTypeItem(int index, Item[] pool) -> (string|null name, string desc):
    Item item = pool[index]
    if item is NameAndTypeInfo:
        name = utf8Item(item.name_index,pool)
        desc = utf8Item(item.descriptor_index,pool)
        return name,desc
    else:
        return null,""

public function methodRefItem(int index, Item[] pool) -> (JvmType::Class|null owner,string name,JvmType::Fun descriptor):
    Item item = pool[index]
    //
    if item is MethodRefInfo:
        string desc
        owner = classItem(item.class_index,pool)
        name, desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseMethodDescriptor(desc)
    else:
        return null

public function fieldRefItem(int index, Item[] pool) -> (JvmType::Class|null owner,string name,JvmType::Any descriptor):
    Item item = pool[index]
    if item is FieldRefInfo:
        string desc
        owner = classItem(item.class_index,pool)
        name,desc = nameAndTypeItem(item.name_and_type_index,pool)
        return owner,name,parseDescriptor(desc)
    else:
        return null

public function numberOrStringItem(int index, Item[] pool) -> Constant|null:
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
    u8 tag,
    byte[] value        
}

type IntegerTree is {
    u8 tag,
    i32 value        
}

type LongTree is {
    u8 tag,
    i64 value        
}

type StringTree is {
    u8 tag,
    Utf8Tree string_index
}

type ClassTree is {
    u8 tag,
    Utf8Tree name_index
}

type NameAndTypeTree is {
    u8 tag,
    Utf8Tree name_index,
    Utf8Tree descriptor_index    
}

type FieldRefTree is { 
    u8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

type MethodRefTree is { 
    u8 tag,
    ClassTree class_index,
    NameAndTypeTree name_and_type_index
}

type InterfaceMethodRefTree is { 
    u8 tag,
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

// The index maps Tree items to their position in the constant pool.
// It can be thought of as a cache which is used during the allocation
// procedure to ensure that identical items are allocated to the same
// position in the pool.
public type Index is util::map

public function Utf8Tree(string utf8) -> Utf8Tree:
    byte[] bytes = String.toUTF8(utf8)
    return {
        tag: CONSTANT_Utf8,
        value: bytes
    }

public function ClassTree(JvmType::Class c) -> ClassTree:
    return {
        tag: CONSTANT_Class,
        name_index: Utf8Tree(classDescriptor(c))
    }

public function add(Item[] pool, Index index, Tree item) -> (Item[] npool, Index nindex):
    int i
    pool,index,i = addHelper(pool,index,item)
    return pool,index

// Add an arbitrary item to the pool, whilst updating the index
// appropriately.  Depending on what type the time is, this will
// recursively allocate items contained within it as necessary.
// Returns the updated pool and index, as well as the position the
// item was allocated in the pool.
function addHelper(Item[] pool, Index index, Tree item) -> (Item[] npool, Index nindex, int idx):
    // first, check if already allocated in pool
    int|null i = lookup(index,item)
    if i != null:
        return pool,index,i
    // second, recursively allocate item
    if item is Utf8Tree:
        index[item] = |pool|
        pool = util::append(pool,item)
    else if item is StringTree:        
        pool,index,i = addHelper(pool,index,item.string_index)
        index[item] = |pool|
        StringInfo info = {tag: item.tag, string_index: i}
        pool = util::append(pool,info)
    else if item is ClassTree:
        pool,index,i = addHelper(pool,index,item.name_index)
        index[item] = |pool|
        ClassInfo info = {tag: item.tag, name_index: i}
        pool = util::append(pool,info)
    // finally, done!
    return pool,index,|pool|-1

// ============================================================
// Parse Descriptors
// ============================================================

function parseDescriptor(string desc) -> JvmType::Any|null:
    JvmType::Any type
    int pos
    type,pos = parseDescriptor(0,desc)
    return type

function parseClassDescriptor(string desc) -> JvmType::Class:    
    desc = String.replace(desc,'/','.')
    int|null idx = String.lastIndexOf(desc,'.')
    string pkg
    string name
    if idx is null:
        pkg = ""
        name = desc
    else:
        pkg = array::slice(desc,0,idx)
        name = array::slice(desc,idx+1,|desc|)
    // FIXME: split out inner classes here.
    return {pkg: pkg, classes:[name]}

function parseDescriptor(int pos, string desc) -> (JvmType::Any|null type, int npos):
    if pos >= |desc|:
        return null
    char lookahead = desc[pos]
    switch lookahead:
        case 'B':
            return JvmType::Boolean,pos+1
        case 'C':
            return JvmType::Char,pos+1
        case 'D':
            return JvmType::Double,pos+1
        case 'F':
            return JvmType::Float,pos+1
        case 'I':
            return JvmType::Int,pos+1
        case 'J':
            return JvmType::Long,pos+1
        case 'S':
            return JvmType::Short,pos+1
        case 'Z':
            return JvmType::Boolean,pos+1
        case 'V':
            return JvmType::Void,pos+1
        case 'L':
            int|null end = String.indexOf(desc,';',pos+1)
            if end is null:
                return null
            type = parseClassDescriptor(array::slice(desc,pos+1,end))
            return type,end+1
        case '[':
            JvmType::Any elem
            elem,pos = parseDescriptor(pos+1,desc)
            return JvmType::Array(elem),pos
    // unknown cases
    return null

function parseMethodDescriptor(string desc) -> JvmType::Fun|null:
    if desc[0] != '(':
        return null
    JvmType::Any param
    JvmType::Any ret
    int pos = 1
    JvmType::Any[] params = [0;0] // FIXME
    while desc[pos] != ')':
        param,pos = parseDescriptor(pos,desc)
        params = util::append(params,param)
    //
    ret,pos = parseDescriptor(pos+1,desc)
    return { ret: ret, params: params }

// ============================================================
// Write Descriptors
// ============================================================

function descriptor(JvmType::Any t) -> string:
    if t is JvmType::Primitive:
        switch t:
            case JvmType::Void:
                return "D"
            case JvmType::Boolean:
                return "Z"
            case JvmType::Byte:
                return "B"
            case JvmType::Char:
                return "C"
            case JvmType::Short:
                return "S"
            case JvmType::Int:
                return "I"
            case JvmType::Long:
                return "J"
            case JvmType::Float:
                return "F"
            default:
                return "D"
    else if t is JvmType::Array:
        return ascii::append("[",descriptor(t.element))
    else if t is JvmType::Class:
        return ascii::append("L",ascii::append(classDescriptor(t),";"))
    else:
        return "" // deadcode

function descriptor(JvmType::Fun t) -> string:
    string desc = "("
    int i = 0
    while i < |t.params|:
        desc = ascii::apend(desc,descriptor(t.params[i]))
        i = i + 1
    return ascii::append(desc,ascii::append(")",descriptor(t.ret)))

function classDescriptor(JvmType::Class ct) -> string:
    string pkg = String.replace(ct.pkg,'.','/')
    bool firstTime
    if pkg == "":
        firstTime=true
    else:
        firstTime=false
    string classes = ""
    // now add class components
    int i = 0
    while i < |ct.classes|:
        string class = ct.classes[i]
        if !firstTime:
            classes = ascii::append(classes,"/")
        firstTime=false
        classes = ascii::append(classes,class)
        i = i + 1
    // done
    return ascii::append(pkg,classes)
