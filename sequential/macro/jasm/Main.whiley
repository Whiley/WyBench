import * from whiley.lang.System
import * from whiley.lang.*
import * from ClassFile
import * from CodeAttr
import * from whiley.io.File

void ::main(System sys, [string] args):
    if |args| == 0:
        sys.out.println("usage: jasm [options] file(s)")
        return
    file = File.Reader(args[0])
    contents = file.read()
    cf = ClassFileReader.readClassFile(contents)
    printClassFile(sys,cf)

void ::printClassFile(System sys, ClassFile cf):
    // First, print out the class and its modifiers
    sys.out.print(classModifiers2str(cf.modifiers))
    sys.out.print("class " + JvmType.toString(cf.type))
    sys.out.print(" extends " + JvmType.toString(cf.super))
    if |cf.interfaces| > 0:
        sys.out.print(" implements")
        for i in cf.interfaces:
            sys.out.print(" ")
            sys.out.print(JvmType.toString(i))
    sys.out.println(":")
    // Now, print out fields
    for field in cf.fields:
        printField(sys,field)
    // and, methods
    for method in cf.methods:
        sys.out.println("") // separator
        printMethod(sys,method)

void ::printField(System sys, FieldInfo field):
    sys.out.print("    ")
    sys.out.print(fieldModifiers2str(field.modifiers))
    sys.out.println(JvmType.toString(field.type) + " " + field.name)

void ::printMethod(System sys, MethodInfo method):
    sys.out.print("    ")
    sys.out.print(methodModifiers2str(method.modifiers))
    sys.out.println(method.name + JvmType.toString(method.type) + ":")
    for attr in method.attributes:
        if attr is CodeAttr:
            printCodeAttr(sys,attr)
    
string classModifiers2str({ClassModifier} modifiers):
    r = " "
    for cm in modifiers:
        switch cm:
            case ACC_PUBLIC:
                r = r + "public "
                break
            case ACC_FINAL:
                r = r + "final "
                break
            case ACC_SUPER:
                r = r + "super "
                break
            case ACC_INTERFACE:
                r = r + "interface "
                break
            case ACC_ABSTRACT:
                r = r + "abstract "
                break
            case ACC_ANNOTATION:
                r = r + "annotation "
                break
            case ACC_ENUM:
                r = r + "enum "
                break
    return r

string fieldModifiers2str({FieldModifier} modifiers):
    r = " "
    for cm in modifiers:
        switch cm:
            case ACC_PUBLIC:
                r = r + "public "
                break
            case ACC_PRIVATE:
                r = r + "private "
                break
            case ACC_PROTECTED:
                r = r + "protected "
                break
            case ACC_STATIC:
                r = r + "static "
                break
            case ACC_FINAL:
                r = r + "final "
                break
            case ACC_VOLATILE:
                r = r + "volatile "
                break
            case ACC_TRANSIENT:
                r = r + "transient "
                break
            case ACC_SYNTHETIC:
                r = r + "synthetic "
                break
            case ACC_ENUM:
                r = r + "enum "
                break
    return r

string methodModifiers2str({MethodModifier} modifiers):
    r = " "
    for cm in modifiers:
        switch cm:
            case ACC_PUBLIC:
                r = r + "public "
                break
            case ACC_PRIVATE:
                r = r + "private "
                break
            case ACC_PROTECTED:
                r = r + "protected "
                break
            case ACC_STATIC:
                r = r + "static "
                break
            case ACC_SYNCHRONIZED:
                r = r + "synchronized "
                break
            case ACC_BRIDGE:
                r = r + "bridge "
                break
            case ACC_VARARGS:
                r = r + "varargs "
                break
            case ACC_NATIVE:
                r = r + "natic "
                break
            case ACC_ABSTRACT:
                r = r + "abstract "
                break
            case ACC_STRICT:
                r = r + "strict "
                break
            case ACC_SYNTHETIC:
                r = r + "synthetic "
                break
    return r

void ::printCodeAttr(System sys, CodeAttr code):
    sys.out.print("        ")
    sys.out.println("Stack=" + String.str(code.maxStack) + ", Locals=" + String.str(code.maxLocals))
    for bc in code.bytecodes:
        sys.out.print("        ")
        sys.out.print(String.str(bc.offset) + ":   ")
        sys.out.println(Bytecode.toString(bc))
