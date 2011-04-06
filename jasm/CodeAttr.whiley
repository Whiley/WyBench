CodeAttr readCodeAttribute([byte] data, [ConstantItem] pool):
    length = be2uint(data[10..14])
    pos = 14
    codes = []
    length = length + 14
    while pos < length:
        code,pos = readBytecode(pos,data,pool)
        debug "READ: " + code2str(code) + "\n"
        codes = codes + [code]
    return {
        maxStack: be2uint(data[6..8]),
        maxLocals: be2uint(data[8..10]),
        bytecodes: codes
    }

(Bytecode,int) readBytecode(int pos, [byte] data, [ConstantItem] pool) throws FormatError:
    opcode = data[pos]
    info = decodeTable[opcode]
    if info ~= null:
        throw {msg: "invalid bytecode"}
    else if info ~= (int,int,int):
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
                idx = be2uint(data[pos+1..pos+2])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+2
            case FMT_I16:
                idx = be2uint(data[pos+1..pos+3])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+3
            case FMT_VARIDX:
                idx = be2uint(data[pos+1..pos+2])
                // need to immediate
                return {offset: pos-14, op: opcode},pos+2                
            case FMT_METHODINDEX16:
                idx = be2uint(data[pos+1..pos+3])
                o,n,t = methodRefItem(idx,pool)
                return {offset: pos-14, op: opcode, owner: o, name: n, type: t},pos+3
            case FMT_FIELDINDEX16:
                idx = be2uint(data[pos+1..pos+3])
                o,n,t = fieldRefItem(idx,pool)
                return {offset: pos-14, op: opcode, owner: o, name: n, type: t},pos+3
            case FMT_CONSTINDEX8:
                idx = be2uint(data[pos+1..pos+2])
                // need to read constant
                return {offset: pos-14, op: opcode},pos+2
            case FMT_CONSTINDEX16:
                idx = be2uint(data[pos+1..pos+3])
                // need to read constant
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TYPEINDEX16:
                idx = be2uint(data[pos+1..pos+3])
                // need to read type
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TARGET16:
                offset = be2uint(data[pos+1..pos+3])
                return {offset: pos-14, op: opcode},pos+3
            case FMT_TARGET32:
                offset = be2uint(data[pos+1..pos+5])
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
                npairs = be2uint(data[pos+4..pos+8])
                pos = pos + (8 * npairs)
                return {offset: offset + 14, op: opcode},pos                
    debug "FAILED ON: " + bytecodeStrings[opcode] + "\n"
    throw {msg: "invalid bytecode"}
