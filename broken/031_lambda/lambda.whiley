import whiley.lang.Array
import whiley.lang.System

type string is (int[] chars)
type nat is (int x) where x >= 0

// ===================================================================== 
// Terms
// =====================================================================

// Define syntax of language
type Variable is {
    string variable
}

type Lambda is {
    string variable,
    Term body
}

type Application is {
    Term lambda,
    Term argument
}

type Term is Lambda | Application | Variable

// ===================================================================== 
// Constructos (for convenience)
// =====================================================================

function Variable(string v) -> (Variable r)
ensures r.variable == v:
    return Variable{variable: v}

function Lambda(string v, Term b) -> (Lambda r)
ensures r.variable == v && r.body == b:
    return Lambda{variable: v, body: b}

function Application(Term l, Term a) -> (Application r)
ensures r.lambda == l && r.argument == a:
    return Application{lambda: l, argument: a}

// ===================================================================== 
// Terms
// =====================================================================

type Value is Lambda

// ===================================================================== 
// Free Variables
// =====================================================================

property freeVariable(Term term, string variable)
where (term is Variable) ==> freeVariable(term,variable)
where (term is Lambda) ==> freeVariable(term,variable)
where (term is Application) ==> freeVariable(term,variable)

property freeVariable(Variable term, string variable)
where term.variable != variable

property freeVariable(Lambda term, string variable)
where term.variable != variable
where freeVariable(term.body,variable)

property freeVariable(Application term, string variable)
where freeVariable(term.lambda,variable)
where freeVariable(term.argument,variable)

// ===================================================================== 
// Well-Formed
// =====================================================================

property wellFormed(Term term, string[] variables)
// No variable under consideration is free
where all { i in 0..|variables| | !freeVariable(term,variables[i]) }

type WF_Term is (Term r)
where wellFormed(r,[" ";0])

type WF_Application is (WF_Term&Application r)

// ===================================================================== 
// Substitution
// =====================================================================

function substitute(WF_Term term, string variable, Term replacement) -> (WF_Term t):
    //
    if term is Variable:
        if term.variable == variable:
            return replacement
        else:
            return term
    else if term is Lambda:
        Term nBody = substitute(term.body,variable,replacement)
        return Lambda{variable: term.variable, body: nBody}
    else:
        Term nLambda = substitute(term.lambda,variable,replacement)
        Term nArgument = substitute(term.argument,variable,replacement)
        return Application{lambda: nLambda, argument: nArgument}
        
// ===================================================================== 
// Reductions
// =====================================================================

function reduce(WF_Term term) -> (WF_Term v):
    if term is Application:        
        return reduce(term)
    else:
        // FIXME: this is where we get stuck
        return term

function reduce(WF_Application term) -> (WF_Term v):
    //
    Term lambda = term.lambda
    Term argument = term.argument
    //
    if lambda is Value && argument is Value:
        // R-App3
        return substitute(lambda.body,lambda.variable,argument)
    else if lambda is Value:
        // R-App2
        term.argument = reduce(argument)
    else:
        // R-App1
        term.lambda = reduce(lambda)
    //
    return term

// =====================================================================
// toString()
// =====================================================================

// function toString(Term term) -> (string r):
//     if term is Variable:
//         return term.variable
//     else if term is Lambda:
//         string result = Array.append("\\",term.variable)
//         result = Array.append(result,".(")
//         result = Array.append(result,toString(term.body))
//         return Array.append(result,")")
//     else:
//         string result = toString(term.lambda)
//         result = Array.append(result," ")
//         return Array.append(result,toString(term.argument))

// =====================================================================
// Main
// =====================================================================

method main():
    // Y-combinator: \x.(x x)
    Term term = Lambda("x",Application(Variable("x"),Variable("x")))
    //debug toString(term)
    