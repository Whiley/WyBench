import whiley.lang.*
import * from whiley.lang.Errors
import * from ClassFile

public ClassFile read(string input) throws SyntaxError:
    tokens = tokenify(input)
    return parse(tokens)

// =======================================================
// Lexer
// =======================================================

define operator as { '{','}','(',')' }

define Number as { int value, int start, int end }
define Identifier as { string id, int start, int end }
define JavaString as { string str, int start, int end }
define Operator as { operator op, int start, int end }
define Token as Number | Identifier | JavaString | Operator

[Token] tokenify(string input) throws SyntaxError:
    index = 0
    tokens = []
    while index < |input|:
        lookahead = input[index]
        if Char.isWhiteSpace(lookahead):
            index = skipWhiteSpace(input,index)
        else if Char.isDigit(lookahead):
            token,index = parseNumber(input,index)
            tokens = tokens + [token]
        else if Char.isLetter(lookahead):
            token,index = parseIdentifier(input,index)
            tokens = tokens + [token]
        else:
            index = index + 1
            token = Operator(lookahead,index-1,index)
    return tokens
    
(Identifier, int) parseIdentifier(string input, int index):    
    start = index
    txt = ""
    // inch forward until end of identifier reached
    while index < |input| && Char.isLetter(input[index]):
        txt = txt + input[index]
        index = index + 1
    return Identifier(txt,start,index),index

(Number, int) parseNumber(string input, int index) throws SyntaxError:    
    start = index
    txt = ""
    // inch forward until end of identifier reached
    while index < |input| && Char.isDigit(input[index]):
        txt = txt + input[index]
        index = index + 1
    return Number(String.toInt(txt),start,index),index
    
int skipWhiteSpace(string input, int index):
    while index < |input| && Char.isWhiteSpace(input[index]):
        index = index + 1
    return index

Identifier Identifier(string identifier, int start, int end):
    return {id: identifier, start: start, end: end}

Number Number(int value, int start, int end):
    return {value: value, start: start, end: end}

Operator Operator(char op, int start, int end):
    return {op: op, start: start, end: end}

// =======================================================
// Parser
// =======================================================

ClassFile parse([Token] tokens) throws SyntaxError:
    modifiers,index = parseClassModifiers(tokens,0)
    if matches("class",tokens,index):
        index = match("class",tokens,index)
    else if matches("interface",tokens,index):
        index = match("interface",tokens,index)
        modifiers = modifiers + {ACC_INTERFACE}
    else:
        throw nSyntaxError("expected class or interface",tokens[index])
    name,index = matchIdentifier(tokens,index)
    return {
        minor_version: 0,
        major_version: 49,
        modifiers: modifiers,
        type: JvmType.Class("",name),
        super: JvmType.JAVA_LANG_OBJECT,
        interfaces: [],
        fields: [],
        methods: []
    }
    
({ClassModifier},int) parseClassModifiers([Token] tokens, int index):
    modifiers = {ACC_SUPER}
    oldIndex = -1
    while index < |tokens| && index != oldIndex:
        oldIndex = index
        token = tokens[index]
        if token is Identifier:
            switch(token.id):
                case "public":
                    modifiers = modifiers + {ACC_PUBLIC}
                    index = index + 1
                    break
                case "final":
                    modifiers = modifiers + {ACC_FINAL}
                    index = index + 1
                    break               
                case "abstract":
                    modifiers = modifiers + {ACC_ABSTRACT}
                    index = index + 1
                    break
                case "strict":
                    modifiers = modifiers + {ACC_STRICT}
                    index = index + 1
                    break
                case "synthetic":
                    modifiers = modifiers + {ACC_SYNTHETIC}
                    index = index + 1
                    break
                case "annotation":
                    modifiers = modifiers + {ACC_ANNOTATION}
                    index = index + 1
                    break
                case "enum":
                    modifiers = modifiers + {ACC_ENUM}
                    index = index + 1
                    break
                case "nosuper":
                    modifiers = modifiers - {ACC_SUPER}
                    index = index + 1
    // finished!
    return modifiers,index

(string,int) matchIdentifier([Token] tokens, int index) throws SyntaxError:
    if index < |tokens|:
        token = tokens[index]
        if token is Identifier:
            return token.id,index+1
        else:
            throw nSyntaxError("identifier expected",token)
    throw SyntaxError("unexpected end-of-file",index,index+1)

int match(string id, [Token] tokens, int index) throws SyntaxError:
    if index < |tokens|:
        token = tokens[index]
        if token is Identifier && token.id == id:
            return index+1
        else:
            throw nSyntaxError("identifier expected",tokens[index])
    throw SyntaxError("unexpected end-of-file",index,index+1)

bool matches(string id, [Token] tokens, int index):
    if index < |tokens|:
        token = tokens[index]
        if token is Identifier:
            return token.id == id
    return false

// =======================================================
// Parser
// =======================================================

SyntaxError nSyntaxError(string msg, Token token):
    return SyntaxError(msg,token.start,token.end)
