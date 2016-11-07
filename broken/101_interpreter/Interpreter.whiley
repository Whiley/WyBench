import whiley.lang.ASCII
import * from Syntax

// ====================================================
// Runtime Error
// ====================================================

public type RuntimeError is { ASCII.string msg }

public function RuntimeError(ASCII.string msg) -> RuntimeError:
    return { msg: msg }

// ====================================================
// Interpreter for our Simple Imperative Language
// ====================================================

public type ValueErr is Value | RuntimeError

// This accepts an object in the form of an Abstract Syntax
// Tree and interprets it to produce a value, or an error of
// some kind.
public function interpret(Stmt[] program) -> (ValueErr r):
    //
    int i = 0
    Environment env = Environment.create()
    //
    while i < |program|:
        // Execute next statement
        ValueErr|Environment result = interpret(env, program[i])
        if result is ValueErr:
            // This indicates either an error occurred, or a return
            // statement was reached.
            return result
        else:
            env = result
        i = i + 1
    //
    fail // should be deadcode

// Interpret a statement to produce a value, an error or an updated
// environment.  An error occurs, for example, if an attempt is made to
// divide by zero.  An updated environment indicates that execution
// should continue onto the next statement in sequence.
private function interpret(Environment env, Stmt s) -> (ValueErr|Environment r):
    //
    // TODO
    return env

// Interpret an expression to produce a value, or an error.  An error
// occurs, for example, if an attempt is made to divide by zero
private function interpret(Environment env, Expr e) -> (ValueErr r):
    // FIXME: we want a match expression here
    if e is Const:
        return e.value
    else:
        return RuntimeError("unknown expression encountered")