import std::ascii
import std::array
import std::filesystem
import std::io
import Environment from Environment

// ====================================================
// A simple calculator for expressions
// ====================================================

int ADD = 0
int SUB = 1
int MUL = 2
int DIV = 3

// binary operation
type BOp is (int x) where ADD <= x && x <= DIV
type BinOp is { BOp op, Expr lhs, Expr rhs } 

// variables
type Var is { ascii::string id }

// list access
type ListAccess is { 
    Expr src, 
    Expr index
} 

// expression tree
type Expr is int |  // constant
    Var |              // variable
    BinOp |            // binary operator
    Expr[] |           // array constructor
    ListAccess         // list access

// values
type Value is int | Value[]

// stmts
type Print is { Expr rhs }
type Set is { ascii::string lhs, Expr rhs }
type Stmt is Print | Set

// ====================================================
// Expression Evaluator
// ====================================================

type RuntimeError is { int[] msg } // FIXME: should be ascii::string

// Evaluate an expression in a given environment reducing either to a
// value, or a runtime error.  The latter occurs if evaluation gets
// "stuck" (e.g. expression is // not well-formed)
function evaluate(Expr e, Environment env) -> Value | RuntimeError:
    //
    if e is int:
        return e
    else if e is Var:
        return getValue(env,e.id)
    else if e is BinOp:
        Value|RuntimeError lhs = evaluate(e.lhs, env)
        Value|RuntimeError rhs = evaluate(e.rhs, env)
        // check if stuck
        if !(lhs is int && rhs is int):
            return {msg: "arithmetic attempted on non-numeric value"}
        // switch statement would be good
        if e.op == ADD:
            return lhs + rhs
        else if e.op == SUB:
            return lhs - rhs
        else if e.op == MUL:
            return lhs * rhs
        else if rhs != 0:
            return lhs / rhs
        return {msg: "divide-by-zero"}
    else if e is Expr[]:
        Value[] r = [0;|e|]
        int i = 0
        while i < |e|:
            Value|RuntimeError v = evaluate(i, env)
            if v is RuntimeError:
                return v
            else:
                r[i] = v
            i = i + 1
        //
        return r
    else if e is ListAccess:
        Value|RuntimeError src = evaluate(e.src, env)
        Value|RuntimeError index = evaluate(e.index, env)
        // santity checks
        if src is Value[] && index is int && index >= 0 && index < |src|:
            return src[index]
        else:
            return {msg: "invalid list access"}
    else:
        return 0 // dead-code

function getValue(Environment env, ascii::string key) -> Value|RuntimeError:
    int i = 0
    //
    while i < |env|:
        if env[i].name == key:
            return env[i].v
        i = i + 1
    //
    return {msg: "invalid environment access"}
    
// ====================================================
// Expression Parser
// ====================================================

type State is { ascii::string input, int pos }
type SyntaxError is { int[] msg, int start, int end } // FIXME: should be ascii::string

function SyntaxError(ascii::string msg, int start, int end) -> SyntaxError:
    return { msg: msg, start: start, end: end }

// Top-level parse method
function parse(State st) -> (Stmt|SyntaxError result, State nst):
    //
    Var keyword
    Var v
    Expr|SyntaxError e
    int start = st.pos
    //
    keyword,st = parseIdentifier(st)
    switch keyword.id:
        case "print":
            e,st = parseAddSubExpr(st)
            if !(e is SyntaxError):
                return {rhs: e},st
            else:
                return e,st // error case
        case "set":
            st = parseWhiteSpace(st)
            v,st = parseIdentifier(st)
            e,st = parseAddSubExpr(st)
            if !(e is SyntaxError):
                return {lhs: v.id, rhs: e},st
            else:
                return e,st // error case
        default:
            return SyntaxError("unknown statement",start,st.pos-1),st

function parseAddSubExpr(State st) -> (Expr|SyntaxError result, State nst):
    //
    Expr|SyntaxError lhs
    Expr|SyntaxError rhs
    // First, pass left-hand side 
    lhs,st = parseMulDivExpr(st)
    //
    if lhs is SyntaxError:
        return lhs,st
    //    
    st = parseWhiteSpace(st)
    // Second, see if there is a right-hand side
    if st.pos < |st.input| && st.input[st.pos] == '+':
        // add expression
        st.pos = st.pos + 1
        rhs,st = parseAddSubExpr(st)        
        if rhs is SyntaxError:
            return rhs,st
        else:
            return {op: ADD, lhs: lhs, rhs: rhs},st
    else if st.pos < |st.input| && st.input[st.pos] == '-':
        // subtract expression
        st.pos = st.pos + 1
        rhs,st = parseAddSubExpr(st)        
        if rhs is SyntaxError:
            return rhs,st
        else:
            return {op: SUB, lhs: lhs, rhs: rhs},st
    // No right-hand side
    return lhs,st

function parseMulDivExpr(State st) -> (Expr|SyntaxError result, State nst):
    // First, parse left-hand side
    Expr|SyntaxError lhs
    Expr|SyntaxError rhs
    lhs,st  = parseTerm(st)
    if lhs is SyntaxError:
        return lhs,st
    //
    st = parseWhiteSpace(st)
    // Second, see if there is a right-hand side
    if st.pos < |st.input| && st.input[st.pos] == '*':
        // add expression
        st.pos = st.pos + 1
        rhs,st = parseMulDivExpr(st)   
        if rhs is SyntaxError:
            return rhs,st
        else:
            return {op: MUL, lhs: lhs, rhs: rhs}, st
    else if st.pos < |st.input| && st.input[st.pos] == '/':
        // subtract expression
        st.pos = st.pos + 1
        rhs,st = parseMulDivExpr(st)        
        if rhs is SyntaxError:
            return rhs,st
        else:
            return {op: DIV, lhs: lhs, rhs: rhs}, st
    // No right-hand side
    return lhs,st

function parseTerm(State st) -> (Expr|SyntaxError result, State nst):
    //
    st = parseWhiteSpace(st)        
    if st.pos < |st.input|:
        if ascii::isLetter(st.input[st.pos]):
            return parseIdentifier(st)
        else if ascii::isDigit(st.input[st.pos]):
            return parseNumber(st)
        else if st.input[st.pos] == '[':
            return parseList(st)
    //
    return SyntaxError("expecting number or variable",st.pos,st.pos),st

function parseIdentifier(State st) -> (Var result, State nst):
    //
    int i = st.pos
    // inch forward until end of identifier reached
    while i < |st.input| && ascii::isLetter(st.input[i]):
        i = i + 1    
    // copy identifier into new array
    int[] txt = [0;i-st.pos]
    txt = array::copy(st.input,st.pos,txt,0,|txt|)
    //
    return {id:txt}, st

function parseNumber(State st) -> (Expr|SyntaxError result, State nst):    
    // inch forward until end of identifier reached
    int start = st.pos
    while st.pos < |st.input| && ascii::isDigit(st.input[st.pos]):
        st.pos = st.pos + 1    
    //
    int|null iv = ascii::parseInt(array::slice(st.input,start,st.pos))
    if iv is null:
        return SyntaxError("Error parsing number",start,st.pos),st
    else:
        return iv, st

function parseList(State st) -> (Expr|SyntaxError result, State nst):
    //
    st.pos = st.pos + 1 // skip '['
    st = parseWhiteSpace(st)
    Expr[] l = [0;0] // initial list
    bool firstTime = true
    while st.pos < |st.input| && st.input[st.pos] != ']':
        Expr|SyntaxError e
        //
        if !firstTime && st.input[st.pos] != ',':
            return SyntaxError("expecting comma",st.pos,st.pos),st
        else if !firstTime:
            st.pos = st.pos + 1 // skip ','
        //
        firstTime = false
        e,st = parseAddSubExpr(st)
        //
        if e is SyntaxError:
            return e,st
        else:
            l = append(l,e)
            st = parseWhiteSpace(st)
    st.pos = st.pos + 1
    return l,st

public function append(Expr[] items, Expr item) -> (Expr[] r):
    //
    Expr[] nitems = [0; |items| + 1]
    int i = 0
    //
    while i < |items| 
    where i >= 0 && i <= |items| && |nitems| == |items|+1
    where all { k in 0..i | nitems[k] == items[k] }:
        nitems[i] = items[i]
        i = i + 1
    //
    nitems[i] = item    
    //
    return nitems

// Parse all whitespace upto end-of-file
function parseWhiteSpace(State st) -> State:
    while st.pos < |st.input| && ascii::isWhiteSpace(st.input[st.pos]):
        st.pos = st.pos + 1
    return st

// ====================================================
// Main Method
// ====================================================

public method main(ascii::string[] args):
    if(|args| == 0):
        io::println("no parameter provided!")
    else:
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        ascii::string input = ascii::fromBytes(file.readAll())
        
        Environment env = Environment::create()
        State st = {pos: 0, input: input}
        while st.pos < |st.input|:
            Stmt s
            any r = parse(st)
            if r is SyntaxError:
                io::println("syntax error")
                io::println(r.msg)
                return
            s,st = r
            Value|RuntimeError v = evaluate(s.rhs,env)
            if v is RuntimeError:
                io::println("runtime error: ")
                io::println(v.msg)
                return
            if s is Set:
                env[s.lhs] = v
            else:
                io::println(r)
            st = parseWhiteSpace(st)
            
