import whiley.lang.ASCII

// ====================================================
// Syntax for our Simple Imperative Language
// ====================================================
//
// This defines the Abstract Syntax Tree for the imperative language,
// which includes values, expressions and statements.

// ====================================================
// Values
// ====================================================
public type Value is int | Value[]

// ====================================================
// Opcodes
// ====================================================

public constant CONST is 0
public constant VAR is 1
public constant ADD is 2
public constant SUB is 3
public constant MUL is 4
public constant DIV is 5
public constant ARRAY is 6
public constant ACCESS is 7

public constant ASSIGN is 8
public constant PRINT is 9

// ====================================================
// Constant Expression
// ====================================================

public type Const is { 
    int opcode, 
    Value value
} where opcode == CONST

public function Const(Value v) -> Const:
    return { opcode: CONST, value: v }

// ====================================================
// Binary Expression
// ====================================================

public type BinaryOp is { 
    int opcode, 
    Expr lhs, 
    Expr rhs 
} where opcode >= ADD && opcode <= DIV

public function BinaryOp(int opcode, Expr l, Expr r) -> BinaryOp
requires ADD <= opcode && opcode <= DIV:
    //
    return { opcode: opcode, lhs: l, rhs: r }

// ====================================================
// Variable Expression
// ====================================================

public type Var is { 
    int opcode,
    ASCII.string name
} where opcode == VAR

public function Var(ASCII.string n) -> Var:
    return {opcode: VAR, name: n}

// ====================================================
// Array Constructor
// ====================================================

public type Array is { 
    int opcode,
    Expr[] elements
} where opcode == ARRAY

public function Array(Expr[] es) -> Array:
    return {opcode: ARRAY, elements: es}

// ====================================================
// Array Access
// ====================================================

public type Access is { 
    int opcode,
    Expr src, 
    Expr index
} where opcode == ACCESS

public function Access(Expr src, Expr index) -> Access:
    return {opcode: ACCESS, src: src, index: index}

// ====================================================
// Expressions
// ====================================================

public type Expr is Const |   // constant
    Var |              // variable
    BinaryOp |         // binary operator
    Array |            // array constructor
    Access             // array access

// ====================================================
// Assignment Statement
// ====================================================

public type Assign is { 
    int opcode,
    ASCII.string lhs, 
    Expr rhs 
} where opcode == ASSIGN

public function Assign(ASCII.string l, Expr r) -> Assign:
    return {opcode: ASSIGN, lhs: l, rhs: r}

// ====================================================
// Print Statement
// ====================================================

public type Print is { 
    int opcode, 
    Expr rhs 
} where opcode == PRINT

public function Print(Expr r) -> Print:
    return {opcode: PRINT, rhs: r}

// ====================================================
// Statements
// ====================================================

public type Stmt is Print | Assign

