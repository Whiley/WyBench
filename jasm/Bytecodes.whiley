// =========== UNIT Bytecodes ==============
define unitCode as { NOP, RET }
define UNIT as { unitCode op }

// =========== BINOP Bytecodes ==============

define  binOpCode as { IADD, IMUL, IDIV, IREM, ISHL, ISHR, IUSHR, IAND, IOR, IXOR, LADD, LMUL, LDIV, LREM, LSHL, LSHR, LUSHR, LAND, LOR, LXOR, FADD, FMUL, FDIV, FREM, DADD, DMUL, DDIV, DREM }
define BINOP as {
    binOpCode op
    }

// =========== STORE Bytecodes ==============

define immStoreCode as { ISTORE_0, ISTORE_1, ISTORE_2, ISTORE_3 }
define storeCode as { ISTORE, LSTORE, FSTORE, DSTORE } ∪ immStoreCode
define STORE as {
    storeCode op, 
    byte index }

// =========== LOAD Bytecodes ==============

define immLoadCode as { ILOAD_0, ILOAD_1, ILOAD_2, ILOAD_3 }
define loadCode as { ILOAD, LLOAD, FLOAD, DLOAD }

define LOAD as {
    loadCode op, 
    byte index }

// =========== BRANCH Bytecodes ==============
define branchCode as { GOTO, IFEQ, IFNE, IFLT, IFGE, IFGT, IFLE }
define BRANCH as {
    branchCode op,  
    int16 offset }

// =========== All Bytecodes ==============
define Bytecode as UNIT | STORE | LOAD | BRANCH

// =========== Translate Bytecodes ==============
[byte] translate1(UNIT unit):
    return [unit.op] // easy!

[byte] translate2(BINOP binop):
    return [binop.op] // easy!

// Translate store bytecodes
[byte] translate3(STORE store):
    if(store.op in immStoreCode):
        return [store.op]
    else:
        return [store.op,store.index]

// Translate load bytecodes
[byte] translate4(LOAD load):
    if(load.op in immLoadCode):
        return [load.op]
    else:
        return [load.op,load.index]
