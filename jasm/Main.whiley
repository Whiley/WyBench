import whiley.io.*

void System::main([string] args):
    if |args| == 0:
        this->usage()
        return
    file = this->openReader(args[0])
    contents = file->read()
    cf = readClassFile(contents)
    this->printClassFile(cf)

void System::usage():
    out->println("usage: jasm [options] file(s)")

void System::printClassFile(ClassFile cf):
    // First, print out the class and its modifiers
    out->print(classModifiers2str(cf.modifiers))
    out->print("class " + type2str(cf.type))
    out->print(" extends " + type2str(cf.super))
    if |cf.interfaces| > 0:
        out->print(" implements")
        for i in cf.interfaces:
            out->print(" ")
            out->print(type2str(i))
    out->println(":")
    // Now, print out fields
    for field in cf.fields:
        this->printField(field)
    // and, methods
    for method in cf.methods:
        out->println("") // separator
        this->printMethod(method)

void System::printField(FieldInfo field):
    out->print("    ")
    out->print(fieldModifiers2str(field.modifiers))
    out->println(type2str(field.type) + " " + field.name)

void System::printMethod(MethodInfo method):
    out->print("    ")
    out->print(methodModifiers2str(method.modifiers))
    out->println(method.name + type2str(method.type) + ":")
    
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
