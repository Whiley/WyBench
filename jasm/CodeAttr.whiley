CodeAttr readCodeAttribute([byte] data, [ConstantItem] pool):
    length = be2uint(data[10..14])
    pos = 14
    codes = []
    while length > 0:
        code,pos = readBytecode(pos,data,pool)
        codes = codes + [code]
        length = length - 1
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
    else if info ~= int:
        return ({offset: pos-14, op: opcode, kind: info},pos+1)
    else:
        return ({offset: pos-14, op: opcode, kind: NOP},pos+1)
