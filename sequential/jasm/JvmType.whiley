// =========== JVM Types ==============

public define Void as 3
public define Boolean as 4
public define Char as 5
public define Float as 6
public define Double as 7
public define Byte as 8
public define Short as 9
public define Int as 10
public define Long as 11

public define Primitive as { Void, Boolean, Char, Float, Double, Byte, Short, Int, Long }
public define Array as { Any element }
public define Class as { string pkg, [string] classes }
public define Ref as Array | Class
public define Fun as { Any ret, [Any] params }
public define Any as Primitive | Ref

public Array Array(Any element):
    return { element: element }

public Class Class(string pkg, string class):
    return {pkg: pkg, classes: [class]}

public Class Class(string pkg, [string] classes):
    return {pkg: pkg, classes: classes}

public Fun Fun(Any ret, [Any] params):
    return {ret: ret, params: params}

// useful constants
public define JAVA_LANG_OBJECT as {pkg: "java.lang", classes: ["Object"]}
public define JAVA_LANG_STRING as {pkg: "java.lang", classes: ["String"]}

public string toString(Any t):
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

public string toString(Fun ft):
    r = "("
    firstTime=true
    for p in ft.params:
        if !firstTime:
            r = r + ", "
        firstTime=false
        r = r + toString(p)
    return r + ")" + toString(ft.ret)
