import std::ascii

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

public int CONST = 0
public int VAR = 1
public int ADD = 2
public int SUB = 3
public int MUL = 4
public int DIV = 5
public int ARRAY = 6
public int ACCESS = 7

public int ASSIGN = 8
public int RETURN = 9

// ====================================================
// Constant Expression
// ====================================================

public type Const is ({ 
    int opcode, 
    Value value
} e) where e.opcode == CONST

public function Const(Value v) -> Const:
    return { opcode: CONST, value: v }

// ====================================================
// Binary Expression
// ====================================================

public type BinaryOp is ({ 
    int opcode, 
    Expr lhs, 
    Expr rhs 
} e) where e.opcode >= ADD && e.opcode <= DIV

public function BinaryOp(int opcode, Expr l, Expr r) -> BinaryOp
requires ADD <= opcode && opcode <= DIV:
    //
    return { opcode: opcode, lhs: l, rhs: r }

// ====================================================
// Variable Expression
// ====================================================

public type Var is ({ 
    int opcode,
    ascii::string name
} e) where e.opcode == VAR

public function Var(ascii::string n) -> Var:
    return {opcode: VAR, name: n}

// ====================================================
// Array Constructor
// ====================================================

public type Array is ({ 
    int opcode,
    Expr[] elements
} e) where e.opcode == ARRAY

public function Array(Expr[] es) -> Array:
    return {opcode: ARRAY, elements: es}

// ====================================================
// Array Access
// ====================================================

public type Access is ({ 
    int opcode,
    Expr src, 
    Expr index
} e) where e.opcode == ACCESS

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

public type Assign is ({ 
    int opcode,
    ascii::string lhs, 
    Expr rhs 
} s) where s.opcode == ASSIGN

public function Assign(ascii::string l, Expr r) -> Assign:
    return {opcode: ASSIGN, lhs: l, rhs: r}

// ====================================================
// Return Statement
// ====================================================

public type Return is ({ 
    int opcode, 
    Expr rhs 
} s) where s.opcode == RETURN

public function Return(Expr r) -> Return:
    return {opcode: RETURN, rhs: r}

// ====================================================
// Statements
// ====================================================

public type Stmt is Return | Assign

