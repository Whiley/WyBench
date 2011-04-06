import whiley.io.*

void System::main([string] args):
    if |args| == 0:
        this->usage()
        return
    file = this->openReader(args[0])
    contents = file->read()
    cf = readClassFile(contents)
    //    out->println(str(cf.interfaces))

void System::usage():
    out->println("usage: jasm [options] file(s)")
