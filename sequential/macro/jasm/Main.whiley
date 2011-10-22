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
    //cf = ClassFileReader.readClassFile(contents)
    try:    
        cf = JasmFileReader.read(String.fromASCII(contents))
        JasmFileWriter.write(sys,cf)
        bytes = ClassFileWriter.write(cf)
        file = File.Writer("Test.class")
        file.write(bytes)
    catch(SyntaxError se):
        sys.out.println("syntax error: " + se.msg)
