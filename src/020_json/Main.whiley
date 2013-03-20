import whiley.lang.*
import nat from whiley.lang.Int
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Char
import * from whiley.lang.Errors

define PAIR as {string key, VALUE val}
define VALUE as real | bool | string | JSON | [VALUE]
define JSON as [PAIR]

(string, nat) readLine(nat pos, string input) requires pos >= 0 && pos <= |input|:
    start = pos
    while pos < |input| && input[pos] != '\n' && input[pos] != '\r' where pos >= 0:
        pos = pos + 1
    line = input[start..pos]
    pos = pos + 1
    if pos < |input| && (input[pos - 1] == '\r' && input[pos] == '\n'):
        pos = pos + 1
    return (line, pos)

nat skipWhiteSpace(nat index, string input) requires index >= 0 && index <= |input|, ensures $ >= 0 && $ <= |input|:
    while index < |input| && isWhiteSpace(input[index]) where index >= 0 && index <= |input|:
        index = index + 1
    return index

(nat, real) parseReal(nat pos, string input) requires pos >= 0 && pos <= |input| throws SyntaxError:
    pos = skipWhiteSpace(pos, input)
    start = pos
    while pos < |input| && (Char.isDigit(input[pos]) || input[pos] == '.') where pos >= 0 && pos <= |input|:
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number", pos, pos)
    return (pos, Real.parse(input[start..pos]))

(nat, string) parseStr(nat pos, string input) requires pos >= 0 && pos <= |input| throws SyntaxError:
    pos = eat(pos, input, "\"")
    start = pos
    while input[pos] != '"':
        pos = pos + 1
    str = input[start..pos]
    pos = eat(pos, input, "\"")
    return (pos, str)

nat eat(nat pos, string input, string pattern) requires pos >= 0 && |pattern| <= |input| && pos + |pattern| <= |input|, ensures $ >=0 && $ <= |input| throws SyntaxError:
    pos = skipWhiteSpace(pos, input)
    for c in pattern where pos >= 0 && pos <= |input|:
        if input[pos] == c:
            pos = pos + 1
        else:
            throw SyntaxError("bad JSON object", pos, pos + 1)
    return pos

(nat, [VALUE]) parseArray(nat pos, string input) requires pos >= 0 && pos <= |input| throws SyntaxError:
    pos = eat(pos, input, "[")
    res = []
    while input[pos] != ']' where pos >= 0 && pos <= |input|:
        pos, val = parseValue(pos, input)
        res = res + [val]
        pos = skipWhiteSpace(pos, input)
        if input[pos] == ',':
            pos = eat(pos, input, ",")
    pos = eat(pos, input, "]")
    return (pos, res)

(nat, VALUE) parseValue(nat pos, string input) requires pos >= 0 && pos <= |input| throws SyntaxError:
    pos = skipWhiteSpace(pos, input)
    if input[pos] == 't' && input[pos + 1] == 'r' && input[pos + 2] == 'u' && input[pos + 3] == 'e':
        pos = pos + 4
        return (pos, true)
    else if input[pos] == 'f' && input[pos + 1] == 'a' && input[pos + 2] == 'l' && input[pos + 3] == 's' && input[pos + 4] == 'e':
        pos = pos + 5
        return (pos, false)
    else if Char.isDigit(input[pos]) || input[pos] == '.':
        return parseReal(pos, input)
    else if input[pos] == '"':
        return parseStr(pos, input)
    else if input[pos] == '{':
        return parseJSON(pos, input)
    else if input[pos] == '[':
        return parseArray(pos, input)
    else:
        throw SyntaxError("bad value", pos, pos + 1)

(nat, PAIR) parsePAIR(nat pos, string input) requires pos >= 0 && pos <= |input| throws SyntaxError:
    pos = skipWhiteSpace(pos, input)
    // empty JSON object
    if input[pos] == '}':
        return (pos, {key: "", val: ""})
    // key
    pos, key = parseStr(pos, input)
    // colon
    pos = eat(pos, input, ":")
    // value
    pos, val = parseValue(pos, input)
    // comma
    pos = skipWhiteSpace(pos, input)
    if input[pos] != '}':
        pos = eat(pos, input, ",")
    return (pos, {key: key, val: val})

(nat, JSON) parseJSON(nat pos, string input) requires pos >= 0 && pos <= |input| throws SyntaxError:
    pos = eat(pos, input, "{")
    res = []
    pos, pair = parsePAIR(pos, input)
    while pair.key != "" where pos >= 0 && pos <= |input|:
        res = res + [pair]
        pos, pair = parsePAIR(pos, input)
    pos = eat(pos, input, "}")
    return (pos, res)

void ::main(System.Console con):
    if |con.args| == 0:
        con.out.println("usage: json <input-file>")
    else:
        file = File.Reader(con.args[0])
        input = String.fromASCII(file.read())
        fpos = 0
        while fpos < |input| where fpos >= 0:
            line, fpos = readLine(fpos, input)
            try:
                lpos, json = parseJSON(0, line)
                con.out.println(json)
            catch(SyntaxError e):
                con.out.print(e.msg)
                con.out.print(": ")
                con.out.print(e.start)
                con.out.print(" - ")
                con.out.print(e.end)

