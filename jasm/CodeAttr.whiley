CodeAttr readCodeAttribute([byte] data, [ConstantItem] pool):
    length = be2uint(data[10..14])
    pos = 14
    codes = []
    while length > 0:
        code,pos = readBytecode(pos,data,pool)
        length = length - 1
    return {
        maxStack: be2uint(data[6..8]),
        maxLocals: be2uint(data[8..10]),
        bytecodes: codes
    }

(Bytecode,int) readBytecode(int pos, [byte] data, [ConstantItem] pool):
    info = decodeTable[data[pos]]
    return ({kind: NOP},pos+1)
