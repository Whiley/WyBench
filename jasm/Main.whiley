import whiley.io.*

void System::main([string] args):
    if |args| == 0:
        this->usage()
        return
    file = this->openReader(args[0])
    contents = file->read()
    // parseClassFile(contents)
    cf = readClassFile(contents)
    if cf ~= FormatError:
        out->println("Format error: " + cf.msg)

void System::usage():
    out->println("usage: jasm [options] file(s)")
