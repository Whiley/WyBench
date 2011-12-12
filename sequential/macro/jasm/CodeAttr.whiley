import whiley.lang.*
import Error from whiley.lang.Errors
import * from ConstantPool
import * from Bytecode

define CodeAttr as {
    string name,
    int maxStack,
    int maxLocals,
    [Bytecode] bytecodes
}

CodeAttr read([byte] data, [ConstantPool.Item] pool) throws Error:
    length = Byte.toUnsignedInt(data[14..10])
    pos = 14
    codes = []
    length = length + 14
    while pos < length:
        code,pos = readBytecode(pos,data,pool)
        codes = codes + [code]
    return {
        name: "Code",
        maxStack: Byte.toUnsignedInt(data[8..6]),
        maxLocals: Byte.toUnsignedInt(data[10..8]),
        bytecodes: codes
    }

(Bytecode,int) readBytecode(int pos, [byte] data, [ConstantPool.Item] pool) throws Error:
    opcode = Byte.toUnsignedInt(data[pos])
    info = decodeTable[opcode]
    if info is null:
        throw {msg: "invalid bytecode"}
    else if info is (int,int,int):
        kind,fmt,type = info
        switch fmt:
            case FMT_EMPTY,
                 FMT_INTNULL,
                 FMT_INTM1,
                 FMT_INT0,
                 FMT_INT1,
                 FMT_INT2,
                 FMT_INT3,
                 FMT_INT4,
                 FMT_INT5:
                return Unit(pos-14, opcode),pos+1
            case FMT_I8:
                idx = Byte.toUnsignedInt(data[pos+1..pos+2])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+2
            case FMT_I16:
                idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+3
            case FMT_VARIDX:
                index = Byte.toUnsignedInt(data[pos+1..pos+2])
                // need to immediate
                return VarIndex(pos-14, opcode, index),pos+2                
            case FMT_VARIDX_I8:
                var = Byte.toUnsignedInt(data[pos+1..pos+2])
                count = Byte.toUnsignedInt(data[pos+2..pos+3])
                return VarIndex(pos-14, opcode, var),pos+3
            case FMT_METHODINDEX16:
                idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                owner,name,type = methodRefItem(idx,pool)
                return MethodIndex(pos-14, opcode, owner, name, type),pos+3
            case FMT_METHODINDEX16_U8_0:
                idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                owner,name,type = methodRefItem(idx,pool)
                count = Byte.toUnsignedInt(data[pos+3..pos+4])
                return MethodIndex(pos-14, opcode, owner, name, type),pos+5
            case FMT_FIELDINDEX16:
                idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                owner,name,type = fieldRefItem(idx,pool)
                return FieldIndex(pos-14, opcode, owner, name, type),pos+3
            case FMT_CONSTINDEX8:
                index = Byte.toUnsignedInt(data[pos+2..pos+1])
                constant = numberOrStringItem(index,pool)
                return ConstIndex(pos-14, opcode, constant),pos+2
            case FMT_CONSTINDEX16:
                index = Byte.toUnsignedInt(data[pos+3..pos+1])
                constant = numberOrStringItem(index,pool)
                return ConstIndex(pos-14, opcode, constant),pos+3
            case FMT_TYPEINDEX16:
                idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                // need to read type
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TYPEAINDEX16:
                idx = Byte.toUnsignedInt(data[pos+3..pos+1])
                // need to read type
                return {offset: pos-14, op: opcode},pos+3
            case FMT_ATYPE:
                idx = Byte.toUnsignedInt(data[pos+1..pos+2])
                // need to decode type
                return {offset: pos-14, op: opcode},pos+2
            case FMT_TARGET16:
                offset = Byte.toUnsignedInt(data[pos+3..pos+1])
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TARGET32:
                offset = Byte.toUnsignedInt(data[pos+5..pos+1])
                return {offset: pos-14, op: opcode},pos+5
            case FMT_TABLESWITCH:
                offset = (pos - 14)
                pos = pos + 1
                padding = 3 - (offset % 4)
                pos = pos + padding
                defaul = Byte.toUnsignedInt(data[pos+4..pos+0])
                low = Byte.toUnsignedInt(data[pos+8..pos+4])
                high = Byte.toUnsignedInt(data[pos+12..pos+8])
                noffsets = (high - low) + 1
                return {offset: offset + 14, op: opcode},pos + 12 + (4 * noffsets)
            case FMT_LOOKUPSWITCH:
                offset = (pos - 14)
                pos = pos + 1
                padding = 3 - (offset % 4)
                pos = pos + padding
                defaul = Byte.toUnsignedInt(data[pos+4..pos+0])
                npairs = Byte.toUnsignedInt(data[pos+8..pos+4])
                return {offset: offset + 14, op: opcode},pos + 8 + (8 * npairs)
    else:
        // this format is only for CONVERT bytecodes
        kind,fmt,from,to = info
        return Unit(pos-14,opcode),pos+1
    debug "FAILED ON: " + bytecodeStrings[opcode] + "\n"
    throw {msg: "invalid bytecode"}
