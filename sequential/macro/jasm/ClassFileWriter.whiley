import whiley.lang.*
import * from ClassFile
import * from ConstantPool
import * from Bytecodes

[byte] write(ClassFile cf):
    constantPool = []
    // write standard classfile header
    bytes = [Int.toUnsignedByte(0xCA),
             Int.toUnsignedByte(0xFE),
             Int.toUnsignedByte(0xBA),
             Int.toUnsignedByte(0xBE)]
    // write version numbers
    bytes = write_u2(bytes,cf.minor_version)
    bytes = write_u2(bytes,cf.major_version)
    // write constant pool
    bytes = write_u2(bytes,|constantPool|)
    //    for poolItem : constantPool:
    //      ???
    // write class info
    bytes = writeModifiers(bytes,cf.modifiers)
    bytes = write_u2(bytes,0) // class pool index
    bytes = write_u2(bytes,0) // super class pool index
    bytes = write_u2(bytes,0) // interface count
    // write fields
    bytes = write_u2(bytes,0) // field count
    // write methods
    bytes = write_u2(bytes,0) // method count
    // write class attributes
    bytes = write_u2(bytes,0) // attribute count
    return bytes

[byte] writeModifiers([byte] bytes, {ClassModifier} modifiers):
    sum = 0
    for cm in modifiers:
        sum = sum + cm
    return write_u2(bytes,sum)

[byte] write_u2([byte] bytes, int u2) requires 0 <= u2 && u2 <= 65535:
    return bytes + Int.toUnsignedBytes(u2)
