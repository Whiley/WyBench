// =========== JVM Types ==============

define Void as 3
define Boolean as 4
define Char as 5
define Float as 6
define Double as 7
define Byte as 8
define Short as 9
define Int as 10
define Long as 11

define Primitive as { Void, Boolean, Char, Float, Double, Byte, Short, Int, Long }
define Array as { Any element }
define Class as { string pkg, [string] classes }
define Ref as Array | Class
define Fun as { Any ret, [Any] params }
define Any as Primitive | Ref

Array Array(Any element):
    return { element: element }

Class Class(string pkg, string class):
    return {pkg: pkg, classes: [class]}

Class Class(string pkg, [string] classes):
    return {pkg: pkg, classes: classes}

Fun Fun(Any ret, [Any] params):
    return {ret: ret, params: params}

// useful constants
define JAVA_LANG_OBJECT as {pkg: "java.lang", classes: ["Object"]}
define JAVA_LANG_STRING as {pkg: "java.lang", classes: ["String"]}

string toString(Any t):
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
        r = t.pkg
        c = ""
        for class in t.classes:
            c = c + "." + class
        if |r| == 0:
            return c[1..]
        else:
            return r + c            
    else if t is Array:
        return toString(t.element) + "[]"
    else:
        return "" // deadcode

string toString(Fun ft):
    r = "("
    firstTime=true
    for p in ft.params:
        if !firstTime:
            r = r + ", "
        firstTime=false
        r = r + toString(p)
    return r + ")" + toString(ft.ret)
