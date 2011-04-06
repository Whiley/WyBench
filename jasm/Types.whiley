// =========== JVM Types ==============

define T_VOID as 3
define T_BOOLEAN as 4
define T_CHAR as 5
define T_FLOAT as 6
define T_DOUBLE as 7
define T_BYTE as 8
define T_SHORT as 9
define T_INT as 10
define T_LONG as 11

define primitive_t as { T_BOOLEAN, T_CHAR, T_FLOAT, T_DOUBLE, T_BYTE, T_SHORT, T_INT, T_LONG }
define array_t as { jvm_t element }
define class_t as { string pkg, [string] classes }
define ref_t as array_t | class_t
define fun_t as { jvm_t ret, [jvm_t] params }
define jvm_t as primitive_t | ref_t

array_t T_ARRAY(jvm_t element):
    return { element: element }

string type2str(jvm_t t):
    if t ~= primitive_t:
        switch t:
            case T_VOID:
                return "void"
            case T_BOOLEAN:
                return "boolean"
            case T_CHAR:
                return "char"
            case T_FLOAT:
                return "float"
            case T_DOUBLE:
                return "double"
            case T_BYTE:
                return "byte"
            case T_SHORT:
                return "short"
            case T_INT:
                return "int"
            case T_LONG:
                return "long"
    else if t ~= class_t:
        r = t.pkg
        c = ""
        for class in t.classes:
            c = c + "." + class
        if |r| == 0:
            return c[1..]
        else:
            return r + c            
    else if t ~= array_t:
        return type2str(t.element) + "[]"
    return "" // unreachable

string type2str(fun_t ft):
    r = "("
    firstTime=true
    for p in ft.params:
        if !firstTime:
            r = r + ", "
        firstTime=false
        r = r + type2str(p)
    return r + ")" + type2str(ft.ret)

int slotSize(primitive_t type) ensures $==1 || $==2:
    if(type == T_DOUBLE || type == T_LONG):
        return 2
    else:
        return 1

// =========== Opcode Types ==============

define intCodes as { 
    ICONST_M1, 
    ICONST_0, 
    ICONST_1, 
    ICONST_2, 
    ICONST_3, 
    ICONST_4, 
    ICONST_5, 
    ILOAD, 
    ILOAD_0, 
    ILOAD_1, 
    ILOAD_2, 
    ILOAD_3, 
    ISTORE, 
    ISTORE_0, 
    ISTORE_1, 
    ISTORE_2, 
    ISTORE_3, 
    IADD, 
    IMUL, 
    IDIV, 
    IREM, 
    ISHL, 
    ISHR, 
    IUSHR, 
    IAND, 
    IOR, 
    IXOR
}

define longCodes as { 
    LCONST_0, 
    LCONST_1, 
    LLOAD, 
    LLOAD_0, 
    LLOAD_1, 
    LLOAD_2, 
    LLOAD_3, 
    LSTORE, 
    LSTORE_0, 
    LSTORE_1, 
    LSTORE_2, 
    LSTORE_3, 
    LADD, 
    LMUL, 
    LDIV, 
    LREM, 
    LSHL, 
    LSHR, 
    LUSHR, 
    LAND, 
    LOR, 
    LXOR 
}

define floatCodes as { 
    FCONST_0, 
    FCONST_1, 
    FLOAD, 
    FLOAD_0, 
    FLOAD_1, 
    FLOAD_2, 
    FLOAD_3, 
    FSTORE, 
    FSTORE_0, 
    FSTORE_1, 
    FSTORE_2, 
    FSTORE_3, 
    FADD, 
    FMUL, 
    FDIV, 
    FREM
}

define doubleCodes as { 
    DCONST_0, 
    DCONST_1, 
    DLOAD, 
    DLOAD_0, 
    DLOAD_1, 
    DLOAD_2, 
    DLOAD_3, 
    DSTORE, 
    DSTORE_0, 
    DSTORE_1, 
    DSTORE_2, 
    DSTORE_3, 
    DADD, 
    DMUL, 
    DDIV, 
    DREM
}

define typedCodes as intCodes ∪ longCodes ∪ floatCodes ∪ doubleCodes

// This method returns the operand type for bytecodes which
//  manipulate primitive types.
primitive_t jvmType(typedCodes opcode):
    if(opcode in intCodes):
        return T_INT
    else if(opcode in longCodes):
        return T_LONG
    else if(opcode in floatCodes):
        return T_FLOAT
    else if(opcode in doubleCodes):
        return T_DOUBLE
    else:
        return T_LONG
