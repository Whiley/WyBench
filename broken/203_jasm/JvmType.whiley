// =========== JVM Types ==============

public constant Void is 3
public constant Boolean is 4
public constant Char is 5
public constant Float is 6
public constant Double is 7
public constant Byte is 8
public constant Short is 9
public constant Int is 10
public constant Long is 11

public constant Primitive is { Void, Boolean, Char, Float, Double, Byte, Short, Int, Long }
public type Array is { Any element }
public type Class is { string pkg, [string] classes }
public type Ref is Array | Class
public type Fun is { Any ret, [Any] params }
public type Any is Primitive | Ref

public function Array(Any element) => Array:
    return { element: element }

public function Class(string pkg, string class) => Class:
    return {pkg: pkg, classes: [class]}

public function Class(string pkg, [string] classes) => Class:
    return {pkg: pkg, classes: classes}

public function Fun(Any ret, [Any] params) => Fun:
    return {ret: ret, params: params}

// useful constants
public constant JAVA_LANG_OBJECT is {pkg: "java.lang", classes: ["Object"]}
public constant JAVA_LANG_STRING is {pkg: "java.lang", classes: ["String"]}

public function toString(Any t) => string:
    if t is Primitive:
        switch t:
            case Void:
                return "void"
            case Boolean:
                return "boolean"
            case Char:
                return "char"
            case Float:
                return "float"
            case Double:
                return "double"
            case Byte:
                return "byte"
            case Short:
                return "short"
            case Int:
                return "int"
            case Long:
                return "long"
            default:
                return "unknown"
    else if t is Class:
        string r = t.pkg
        string c = ""
        for class in t.classes:
            c = c ++ "." ++ class
        if |r| == 0:
            return c[1..]
        else:
            return r ++ c            
    else if t is Array:
        return toString(t.element) ++ "[]"
    else:
        return "" // deadcode

public function toString(Fun ft) => string:
    string r = "("
    bool firstTime=true
    for p in ft.params:
        if !firstTime:
            r = r ++ ", "
        firstTime=false
        r = r ++ toString(p)
    return r ++ ")" ++ toString(ft.ret)
