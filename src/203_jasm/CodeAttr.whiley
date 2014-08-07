import whiley.lang.*
import Error from whiley.lang.Errors
import * from ConstantPool
import Bytecode from Bytecode

public type CodeAttr is {
    string name,
    int maxStack,
    int maxLocals,
    [Bytecode] bytecodes
}

function read([byte] data, [ConstantPool.Item] pool) => CodeAttr
throws Error:
    int length = Byte.toUnsignedInt(data[14..10])
    int pos = 14
    [Bytecode] codes = []
    Bytecode code
    //
    length = length + 14
    while pos < length:
        code,pos = readBytecode(pos,data,pool)
        codes = codes ++ [code]
    return {
        name: "Code",
        maxStack: Byte.toUnsignedInt(data[8..6]),
        maxLocals: Byte.toUnsignedInt(data[10..8]),
        bytecodes: codes
    }

function readBytecode(int pos, [byte] data, [ConstantPool.Item] pool) => (Bytecode,int) 
throws Error:
    int kind, int fmt, int type, int from, int to
    int opcode = Byte.toUnsignedInt(data[pos])
    Bytecode.Info info = Bytecode.decodeTable[opcode]
    //
    if info is null:
        throw {msg: "invalid bytecode"}
    else if info is (int,int,int):
        kind,fmt,type = info
        switch fmt:
            case Bytecode.FMT_EMPTY,
                 Bytecode.FMT_INTNULL,
                 Bytecode.FMT_INTM1,
                 Bytecode.FMT_INT0,
                 Bytecode.FMT_INT1,
                 Bytecode.FMT_INT2,
                 Bytecode.FMT_INT3,
                 Bytecode.FMT_INT4,
                 Bytecode.FMT_INT5:
                return Bytecode.Unit(pos-14, opcode),pos+1
            case Bytecode.FMT_I8:
                int idx = Byte.toUnsignedInt(data[pos+1..pos+2])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+2
            case Bytecode.FMT_I16:
                int idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+3
            case Bytecode.FMT_VARIDX:
                int index = Byte.toUnsignedInt(data[pos+1..pos+2])
                // need to immediate
                return Bytecode.VarIndex(pos-14, opcode, index),pos+2                
            case Bytecode.FMT_VARIDX_I8:
                int var = Byte.toUnsignedInt(data[pos+1..pos+2])
                int count = Byte.toUnsignedInt(data[pos+2..pos+3])
                return Bytecode.VarIndex(pos-14, opcode, var),pos+3
            case Bytecode.FMT_METHODINDEX16:
                JvmType.Ref owner, JvmType.Fun jvmtype, string name
                //
                int idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                owner,name,jvmtype = methodRefItem(idx,pool)
                return Bytecode.MethodIndex(pos-14, opcode, owner, name, jvmtype),pos+3
            case Bytecode.FMT_METHODINDEX16_U8_0:
                JvmType.Ref owner, JvmType.Fun jvmtype, string name
                //
                int idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                owner,name,jvmtype = methodRefItem(idx,pool)
                int count = Byte.toUnsignedInt(data[pos+3..pos+4])
                return Bytecode.MethodIndex(pos-14, opcode, owner, name, jvmtype),pos+5
            case Bytecode.FMT_FIELDINDEX16:
                JvmType.Ref owner, JvmType.Any jvmtype, string name
                //
                int idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                owner,name,jvmtype = fieldRefItem(idx,pool)
                return Bytecode.FieldIndex(pos-14, opcode, owner, name, jvmtype),pos+3
            case Bytecode.FMT_CONSTINDEX8:
                int index = Byte.toUnsignedInt(data[pos+2..pos+1])
                Constant constant = numberOrStringItem(index,pool)
                return Bytecode.ConstIndex(pos-14, opcode, constant),pos+2
            case Bytecode.FMT_CONSTINDEX16:
                int index = Byte.toUnsignedInt(data[pos+3..pos+1])
                Constant constant = numberOrStringItem(index,pool)
                return Bytecode.ConstIndex(pos-14, opcode, constant),pos+3
            case Bytecode.FMT_TYPEINDEX16:
                int idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                // need to read type
                return {offset: pos-14, op: opcode},pos+3
            case Bytecode.FMT_TYPEAINDEX16:
                int idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                // need to read type
                return {offset: pos-14, op: opcode},pos+3
            case Bytecode.FMT_ATYPE:
                int idx = Byte.toUnsignedInt(data[pos+1..pos+2])
                // need to decode type
                return {offset: pos-14, op: opcode},pos+2
            case Bytecode.FMT_TARGET16:
                int offset = Byte.toUnsignedInt(data[pos+3..pos+1])
                return {offset: pos-14, op: opcode},pos+3
            case Bytecode.FMT_TARGET32:
                int offset = Byte.toUnsignedInt(data[pos+5..pos+1])
                return {offset: pos-14, op: opcode},pos+5
            case Bytecode.FMT_TABLESWITCH:
                int offset = (pos - 14)
                int padding = 3 - (offset % 4)
                pos = pos + 1
                pos = pos + padding
                int defaul = Byte.toUnsignedInt(data[pos+4..pos+0])
                int low = Byte.toUnsignedInt(data[pos+8..pos+4])
                int high = Byte.toUnsignedInt(data[pos+12..pos+8])
                int noffsets = (high - low) + 1
                return {offset: offset + 14, op: opcode},pos + 12 + (4 * noffsets)
            case Bytecode.FMT_LOOKUPSWITCH:
                int offset = (pos - 14)
                int padding = 3 - (offset % 4)
                pos = pos + 1
                pos = pos + padding
                int defaul = Byte.toUnsignedInt(data[pos+4..pos+0])
                int npairs = Byte.toUnsignedInt(data[pos+8..pos+4])
                return {offset: offset + 14, op: opcode},pos + 8 + (8 * npairs)
    else:
        // this format is only for CONVERT bytecodes
        kind,fmt,from,to = info
        return Bytecode.Unit(pos-14,opcode),pos+1
    debug "FAILED ON: " ++ Bytecode.bytecodeStrings[opcode] ++ "\n"
    throw {msg: "invalid bytecode"}
