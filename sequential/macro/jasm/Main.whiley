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
    contents = String.fromASCII(contents)
    //cf = ClassFileReader.readClassFile(contents)
    try:    
        cf = JasmFileReader.read(contents)
        JasmFileWriter.write(sys,cf)
        bytes = ClassFileWriter.write(cf)
        file = File.Writer("Test.class")
        file.write(bytes)
    catch(SyntaxError se):
        sys.out.println("syntax error: " + se.msg)
        sys.out.println("")
        context,start = getContext(se,contents)        
        sys.out.print(context)
        end = se.end - start
        start = se.start - start
        for i in 0..end:          
            if i >= start:
                sys.out.print("^")
            else if context[i] == '\t':
                sys.out.print("\t")
            else:
                sys.out.print(" ")
        // done

(string,int) ::getContext(SyntaxError error, string contents):
    index = 0
    while index < |contents|:        
        nindex = parseLine(contents,index)
        if index < error.start && error.start < nindex:
            // match            
            return contents[index..nindex],index
        index = nindex
    return "",index

int parseLine(string contents, int index):
    start = index
    while index < |contents| && contents[index] != '\n':
        index = index + 1
    return index+1
