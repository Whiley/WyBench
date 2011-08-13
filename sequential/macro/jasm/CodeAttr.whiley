CodeAttr readCodeAttribute([byte] data, [ConstantItem] pool):
    length = toUnsignedInt(data[14..10])
    pos = 14
    codes = []
    length = length + 14
    while pos < length:
        code,pos = readBytecode(pos,data,pool)
        debug "READ: " + code2str(code) + "\n"
        codes = codes + [code]
    return {
        maxStack: toUnsignedInt(data[8..6]),
        maxLocals: toUnsignedInt(data[10..8]),
        bytecodes: codes
    }

(Bytecode,int) readBytecode(int pos, [byte] data, [ConstantItem] pool) throws FormatError:
    opcode = toUnsignedInt(data[pos])
    info = decodeTable[opcode]
    if info is null:
        throw {msg: "invalid bytecode"}
    else if info is (int,int,int):
        kind,fmt,type = info
        switch fmt:
            case FMT_EMPTY:
            case FMT_INTM1:
            case FMT_INT0:
            case FMT_INT1:
            case FMT_INT2:
            case FMT_INT3:
                return Unit(pos-14, opcode),pos+1
            case FMT_I8:
                idx = toUnsignedInt(data[pos+2..pos+1])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+2
            case FMT_I16:
                idx = toUnsignedInt(data[pos+3..pos+1])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+3
            case FMT_VARIDX:
                index = toUnsignedInt(data[pos+2..pos+1])
                // need to immediate
                return VarIndex(pos-14, opcode, index),pos+2                
            case FMT_METHODINDEX16:
                idx = toUnsignedInt(data[pos+3..pos+1])
                owner,name,type = methodRefItem(idx,pool)
                return MethodIndex(pos-14, opcode, owner, name, type),pos+3
            case FMT_FIELDINDEX16:
                idx = toUnsignedInt(data[pos+3..pos+1])
                owner,name,type = fieldRefItem(idx,pool)
                return FieldIndex(pos-14, opcode, owner, name, type),pos+3
            case FMT_CONSTINDEX8:
                index = toUnsignedInt(data[pos+2..pos+1])
                constant = numberOrStringItem(index,pool)
                return ConstIndex(pos-14, opcode, constant),pos+2
            case FMT_CONSTINDEX16:
                index = toUnsignedInt(data[pos+3..pos+1])
                constant = numberOrStringItem(index,pool)
                return ConstIndex(pos-14, opcode, constant),pos+3
            case FMT_TYPEINDEX16:
                idx = toUnsignedInt(data[pos+3..pos+1])
                // need to read type
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TARGET16:
                offset = toUnsignedInt(data[pos+3..pos+1])
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TARGET32:
                offset = toUnsignedInt(data[pos+5..pos+1])
                return {offset: pos-14, op: opcode},pos+5
            case FMT_LOOKUPSWITCH:
                offset = (pos - 14)
                pos = pos + 1
                tmp = (offset / 4) * 4
                if tmp != offset:
                    padding = (tmp+4)-offset
                else:
                    padding = 0
                pos = pos + padding
                npairs = toUnsignedInt(data[pos+8..pos+4])
                pos = pos + (8 * npairs)
                return {offset: offset + 14, op: opcode},pos
    else if info is (int,int,int,int):
        // these are all convert bytecodes
        kind,fmt,fromType,toType = info   
        if kind == CONVERT && fmt == FMT_EMPTY:
            return Unit(pos-14, opcode)                      
    debug "FAILED ON: " + bytecodeStrings[opcode] + "\n"
    throw {msg: "invalid bytecode"}
