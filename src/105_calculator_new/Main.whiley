import whiley.lang.*
import nat from whiley.lang.Int
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Char
import * from whiley.lang.Errors

define RuntimeError as {string msg}

(nat, string) readLine(nat pos, string input) requires pos >= 0 && pos <= |input|:
    start = pos
    while pos < |input| && input[pos] != '\n' && input[pos] != '\r' where pos >= 0:
        pos = pos + 1
    line = input[start..pos]
    pos = pos + 1
    if pos < |input| && input[pos - 1] == '\r' && input[pos] == '\n':
        pos = pos + 1
    return (pos, line)

nat skipWhiteSpace(nat pos, string input) requires pos >= 0 && pos <= |input|, ensures $ >= 0 && $ <= |input|:
    while pos < |input| && isWhiteSpace(input[pos]) where pos >= 0:
        pos = pos + 1
    return pos

(nat, string) readReal(nat pos, string input) requires pos >= 0 && pos <= |input| throws SyntaxError:
    start = pos
    while pos < |input| && (Char.isDigit(input[pos]) || input[pos] == '.') where pos >= 0:
        pos = pos + 1
    if pos == start:
        throw SyntaxError("missing number", pos, pos)
    return (pos, input[start..pos])
    //return (pos, Real.parse(input[start..pos]) * 1.0)

[string] parseLine(nat pos, string line) requires pos >= 0 && pos <= |line| throws SyntaxError:
    res = []
    spec = ["+", "-", "*", "/", "(", ")"]
    pos = skipWhiteSpace(pos, line)
    while pos < |line| where pos >= 0:
        if Char.isDigit(line[pos]) || line[pos] == '.':
            pos, ele = readReal(pos, line)
            res = res + [ele]
        else if ("" + line[pos]) in spec:
            res = res + ["" + line[pos]]
            pos = pos + 1
        else:
            throw SyntaxError("unexpected character", pos, pos)
        pos = skipWhiteSpace(pos, line)
    return res

([string], [string]) doInline([string] stack, [string] res, string ele) requires ele in ["+", "-"] && |stack| > 0 && stack[0] in ["*", "/", "("]:
    res = res + [stack[0]]
    stack = stack[1..]
    if stack[0] == "(":
        stack = [ele] + stack
    else: //if stack[0] == "+" || stack[0] == "-":
        res = res + [stack[0]]
        stack = [ele] + stack[1..]
    return (stack, res)

[string] in2suf([string] inexp) throws RuntimeError:
    res = []
    stack = ["("] // heading "("

    for ele in inexp:
        if Char.isDigit(ele[0]) || ele[0] == '.':
            res = res + [ele]
        else if ele == "(":
            stack = [ele] + stack
        else if ele == "*" || ele == "/":
            assert |stack| > 0
            if stack[0] == "(" || stack[0] == "+" || stack[0] == "-":
                stack = [ele] + stack
            else if stack[0] == "*" || stack[0] == "/":
                res = res + [stack[0]]
                stack = [ele] + stack[1..]
            else:
                throw {msg: "bad element in expression"}
        else if ele == "+" || ele == "-":
            assert |stack| > 0
            if stack[0] == "(":
                stack = [ele] + stack
            else if stack[0] == "+" || stack[0] == "-":
                res = res + [stack[0]]
                stack = [ele] + stack[1..]
            else if stack[0] == "*" || stack[0] == "/":
                stack, res = doInline(stack, res, ele)
            else:
                throw {msg: "bad element in expression"}
        else if ele == ")":
            assert |stack| > 0
            while stack[0] != "(" where |stack| > 0:
                res = res + [stack[0]]
                stack = stack[1..]
            stack = stack[1..] // remove "("
        else:
            throw {msg: "bad element in expression"}

    // clean up remaining tail
    assert |stack| > 0
    while stack[0] != "(" where |stack| > 0:
        res = res + [stack[0]]
        stack = stack[1..]
    stack = stack[1..] // remove the heading "("
    assert |stack| == 0

    return res
 
real calc([string] sufexp) requires |sufexp| > 0 throws SyntaxError:
    stack = []

    for ele in sufexp:
        if Char.isDigit(ele[0]) || ele[0] == '.':
            stack = [Real.parse(ele) * 1.0] + stack
        //switch (ele):
        //    case "+":
        //        r = stack[1] + stack[0]
        //        stack = [r] + stack[2..]
        //        break
        //    case "-":
        //        r = stack[1] - stack[0]
        //        stack = [r] + stack[2..]
        //        break
        //    case "*":
        //        r = stack[1] * stack[0]
        //        stack = [r] + stack[2..]
        //        break
        //    case "/":
        //        r = stack[1] / stack[0]
        //        stack = [r] + stack[2..]
        //        break
        if ele == "+":
            assert |stack| >= 2
            r = stack[1] + stack[0]
            stack = [r] + stack[2..]
        else if ele == "-":
            assert |stack| >= 2
            r = stack[1] - stack[0]
            stack = [r] + stack[2..]
        else if ele == "*":
            assert |stack| >= 2
            r = stack[1] * stack[0]
            stack = [r] + stack[2..]
        else if ele == "/":
            assert |stack| >= 2
            r = stack[1] / stack[0]
            stack = [r] + stack[2..]
 
    assert |stack| == 1
    return stack[0]

void ::main(System.Console con):
    if |con.args| == 0:
        con.out.println("usage: calc <input-file>")
    else:
        file = File.Reader(con.args[0])
        input = String.fromASCII(file.read())
        fpos = 0
        while fpos < |input| where fpos >= 0:
            fpos, line = readLine(fpos, input)
            try:
                inexp = parseLine(0, line)
                sufexp = in2suf(inexp)
                if |sufexp| > 0:
                    con.out.println(Real.toDecimal(calc(sufexp), 10))
            catch(RuntimeError e):
                con.out.println(e.msg)
            catch(SyntaxError e):
                con.out.print(e.msg)
                con.out.print(": ")
                con.out.print(e.start)
                con.out.print(" - ")
                con.out.println(e.end)

