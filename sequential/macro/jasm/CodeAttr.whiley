CodeAttr readCodeAttribute([byte] data, [ConstantItem] pool):
    length = uint(data[14..10])
    pos = 14
    codes = []
    length = length + 14
    while pos < length:
        code,pos = readBytecode(pos,data,pool)
        debug "READ: " + code2str(code) + "\n"
        codes = codes + [code]
    return {
        maxStack: uint(data[8..6]),
        maxLocals: uint(data[10..8]),
        bytecodes: codes
    }

(Bytecode,int) readBytecode(int pos, [byte] data, [ConstantItem] pool) throws FormatError:
    opcode = uint(data[pos])
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
                return {offset: pos-14, op: opcode},pos+1
            case FMT_I8:
                idx = uint(data[pos+2..pos+1])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+2
            case FMT_I16:
                idx = uint(data[pos+3..pos+1])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+3
            case FMT_VARIDX:
                idx = uint(data[pos+2..pos+1])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+2                
            case FMT_METHODINDEX16:
                idx = uint(data[pos+3..pos+1])
                o,n,t = methodRefItem(idx,pool)
                return {offset: pos-14, op: opcode, owner: o, name: n, type: t},pos+3
            case FMT_FIELDINDEX16:
                idx = uint(data[pos+3..pos+1])
                o,n,t = fieldRefItem(idx,pool)
                return {offset: pos-14, op: opcode, owner: o, name: n, type: t},pos+3
            case FMT_CONSTINDEX8:
                idx = uint(data[pos+2..pos+1])
                // need to read constant
                return {offset: pos-14, op: opcode},pos+2
            case FMT_CONSTINDEX16:
                idx = uint(data[pos+3..pos+1])
                // need to read constant
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TYPEINDEX16:
                idx = uint(data[pos+3..pos+1])
                // need to read type
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TARGET16:
                offset = uint(data[pos+3..pos+1])
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TARGET32:
                offset = uint(data[pos+5..pos+1])
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
                npairs = uint(data[pos+8..pos+4])
                pos = pos + (8 * npairs)
                return {offset: offset + 14, op: opcode},pos                
    debug "FAILED ON: " + bytecodeStrings[opcode] + "\n"
    throw {msg: "invalid bytecode"}
