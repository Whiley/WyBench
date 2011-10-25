import Bytecode from Bytecode
import * from ConstantPool

public define ClassFile as {
    int minor_version,
    int major_version,
    {ClassModifier} modifiers,
    JvmType.Class type,
    JvmType.Class super,
    [JvmType.Class] interfaces,
    [FieldInfo] fields,
    [MethodInfo] methods
}

public define FieldInfo as {
    {FieldModifier} modifiers,
    string name,
    JvmType.Any type,
    [AttributeInfo] attributes   
}

public FieldInfo FieldInfo({FieldModifier} modifiers, string name, JvmType.Any type, [AttributeInfo] attributes):
    return {
        modifiers: modifiers,
        name: name,
        type: type,
        attributes: attributes
    }

public define MethodInfo as {
    {MethodModifier} modifiers,
    string name,
    JvmType.Fun type,
    [AttributeInfo] attributes   
}

public MethodInfo MethodInfo({MethodModifier} modifiers, string name, JvmType.Fun type, [AttributeInfo] attributes):
    return {
        modifiers: modifiers,
        name: name,
        type: type,
        attributes: attributes
    }

public define UnknownAttr as {
    string name,
    [byte] data
}

define TmpCodeAttr as {
    int maxStack,
    int maxLocals,
    [Bytecode] bytecodes
}

// The following is a hack, because we cannot properly define an
// unknown attribute.
define AttributeInfo as UnknownAttr | TmpCodeAttr

define ACC_PUBLIC as 0x0001
define ACC_PRIVATE as 0x0002
define ACC_PROTECTED as 0x0004
define ACC_STATIC as 0x0008
define ACC_FINAL as  0x0010
define ACC_SUPER as  0x0020
define ACC_SYNCHRONIZED as  0x0020
define ACC_VOLATILE as 0x0040
define ACC_BRIDGE as 0x0040
define ACC_TRANSIENT as 0x0080
define ACC_VARARGS as 0x0080
define ACC_NATIVE as 0x0100
define ACC_INTERFACE as 0x0200
define ACC_ABSTRACT as 0x0400
define ACC_STRICT as 0x0800
define ACC_SYNTHETIC as 0x1000
define ACC_ANNOTATION as 0x2000
define ACC_ENUM as 0x4000

define ClassModifier as {
    ACC_PUBLIC,
    ACC_FINAL,
    ACC_SUPER,
    ACC_INTERFACE,
    ACC_ABSTRACT,
    ACC_SYNTHETIC,
    ACC_ANNOTATION,
    ACC_ENUM
}

define FieldModifier as {
    ACC_PUBLIC, 
    ACC_PRIVATE,
    ACC_PROTECTED,
    ACC_STATIC,
    ACC_FINAL,
    ACC_VOLATILE,
    ACC_TRANSIENT,
    ACC_SYNTHETIC,
    ACC_ENUM
}

define MethodModifier as {
    ACC_PUBLIC, 
    ACC_PRIVATE,
    ACC_PROTECTED,
    ACC_STATIC,
    ACC_FINAL,
    ACC_SYNCHRONIZED,
    ACC_BRIDGE,
    ACC_VARARGS,
    ACC_NATIVE,
    ACC_ABSTRACT,
    ACC_STRICT,
    ACC_SYNTHETIC
}

define Modifier as ClassModifier | FieldModifier | MethodModifier

// compute the constant pool for the given class
public ([Item],Index) constantPool(ClassFile cf):
    pool = [
        // We initialise the first item of the constant pool with a 
        // dummy.  This is because pool indices start from 1, not 0.  
        // Therefore, to avoid subtracting 1 from every index we just set
        // the first as a dummy.
        {tag: CONSTANT_Integer, value: 0}
    ]
    index = {->}
    pool,index = add(pool,index,ClassTree(cf.type))
    pool,index = add(pool,index,ClassTree(cf.super))
    // add interface types
    for interface in cf.interfaces:
        pool,index = add(pool,index,ClassTree(interface))
    // add field information
    for f in cf.fields:
        pool,index = add(pool,index,Utf8Tree(f.name))
        pool,index = add(pool,index,Utf8Tree(descriptor(f.type)))
        // TODO: include attributes
    return pool,index
