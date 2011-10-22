import whiley.lang.*
import * from ClassFile
import * from ConstantPool
import * from Bytecodes

[byte] write(ClassFile cf):
    pool,index = constantPool(cf)
    // write standard classfile header
    bytes = [Int.toUnsignedByte(0xCA),
             Int.toUnsignedByte(0xFE),
             Int.toUnsignedByte(0xBA),
             Int.toUnsignedByte(0xBE)]
    // write version numbers
    bytes = write_u2(bytes,cf.minor_version)
    bytes = write_u2(bytes,cf.major_version)
    // write constant pool
    bytes = write_u2(bytes,|pool|)
    for i in 1..|pool|:
        bytes = writePoolItem(bytes,pool[i])
    // write class info
    bytes = writeModifiers(bytes,cf.modifiers)
    bytes = write_u2(bytes,index[ClassTree(cf.type)])
    bytes = write_u2(bytes,index[ClassTree(cf.super)])
    bytes = write_u2(bytes,|cf.interfaces|)
    for interface in cf.interfaces:
        bytes = write_u2(bytes,index[ClassTree(interface)])
    // write fields    
    bytes = write_u2(bytes,|cf.fields|) // field count
    for field in cf.fields:
        bytes = writeField(bytes,index,field)
    // write methods
    bytes = write_u2(bytes,0) // method count
    // write class attributes
    bytes = write_u2(bytes,0) // attribute count
    return bytes

[byte] writePoolItem([byte] bytes, ConstantPool.Item item):
    if item is ConstantPool.StringInfo:
        bytes = write_u1(bytes,item.tag)
        bytes = write_u2(bytes,item.string_index)
    else if item is ConstantPool.ClassInfo:
        bytes = write_u1(bytes,item.tag)
        bytes = write_u2(bytes,item.name_index)
    else if item is ConstantPool.Utf8Info:
        bytes = write_u1(bytes,item.tag)        
        bytes = write_u2(bytes,|item.value|)
        bytes = bytes + item.value
    else if item is ConstantPool.IntegerInfo|ConstantPool.LongInfo:
        bytes = write_u1(bytes,item.tag)        
        debug "Need to implement writePoolItem(ConstantPool.IntegerInfo)\n"
    else if item is ConstantPool.FieldRefInfo|ConstantPool.MethodRefInfo|ConstantPool.InterfaceMethodRefInfo:
        bytes = write_u1(bytes,item.tag)        
        bytes = write_u2(bytes,item.class_index)
        bytes = write_u2(bytes,item.name_and_type_index)
    else if item is ConstantPool.NameAndTypeInfo:
        bytes = write_u1(bytes,item.tag)
        bytes = write_u2(bytes,item.name_index)
        bytes = write_u2(bytes,item.descriptor_index)
    // done!
    return bytes

[byte] writeModifiers([byte] bytes, {ClassModifier} modifiers):
    sum = 0
    for cm in modifiers:
        sum = sum + cm
    return write_u2(bytes,sum)

// ============================================================
// Fields
// ============================================================

[byte] writeField([byte] bytes, Index index, FieldInfo field):
    bytes = writeModifiers(bytes, field.modifiers)
    bytes = write_u2(bytes, index[Utf8Tree(field.name)])
    bytes = write_u2(bytes, index[Utf8Tree(descriptor(field.type))])
    bytes = write_u2(bytes, 0) // attribute count
    return bytes

// ============================================================
// Methods
// ============================================================

// ============================================================
// Misc
// ============================================================

[byte] write_u1([byte] bytes, int u1) requires 0 <= u1 && u1 <= 255:
    return bytes + [Int.toUnsignedByte(u1)]

[byte] write_u2([byte] bytes, int u2) requires 0 <= u2 && u2 <= 65535:
    low = u2 % 256
    high = u2 / 256
    return bytes + [Int.toUnsignedByte(high),Int.toUnsignedByte(low)]
