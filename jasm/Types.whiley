// =========== JVM Types ==============

define T_VOID as 3
define T_BOOLEAN as 4
define T_CHAR as 5
define T_FLOAT as 6
define T_DOUBLE as 7
define T_BYTE as 8
define T_SHORT as 9
define T_INT as 10
define T_LONG as 11

define primitive_t as { T_BOOLEAN, T_CHAR, T_FLOAT, T_DOUBLE, T_BYTE, T_SHORT, T_INT, T_LONG }
define array_t as { jvm_t element }
define class_t as { string pkg, [string] classes }
define ref_t as array_t | class_t
define fun_t as { jvm_t ret, [jvm_t] params }
define jvm_t as primitive_t | ref_t

array_t T_ARRAY(jvm_t element):
    return { element: element }

string type2str(jvm_t t):
    if t ~= primitive_t:
        switch t:
            case T_VOID:
                return "void"
            case T_BOOLEAN:
                return "boolean"
            case T_CHAR:
                return "char"
            case T_FLOAT:
                return "float"
            case T_DOUBLE:
                return "double"
            case T_BYTE:
                return "byte"
            case T_SHORT:
                return "short"
            case T_INT:
                return "int"
            case T_LONG:
                return "long"
    else if t ~= class_t:
        r = t.pkg
        c = ""
        for class in t.classes:
            c = c + "." + class
        if |r| == 0:
            return c[1..]
        else:
            return r + c            
    else if t ~= array_t:
        return type2str(t.element) + "[]"
    return "" // unreachable

string type2str(fun_t ft):
    r = "("
    firstTime=true
    for p in ft.params:
        if !firstTime:
            r = r + ", "
        firstTime=false
        r = r + type2str(p)
    return r + ")" + type2str(ft.ret)
