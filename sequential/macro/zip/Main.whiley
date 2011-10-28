import whiley.lang.*
import * from whiley.lang.Errors
import * from whiley.lang.System
import * from whiley.io.File

import * from ZipFile

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    contents = file.read()
    try:
        zf = ZipFile(contents)
        // Ok, this is a valid zip file, so print out the information
        // in a format similar to "unzip -v".
        sys.out.println(" Length   Method  Size   CRC-32  Name")
        sys.out.println("-------- -------- ------ -------- ----")
        rawSize = 0
        size = 0
        for e in zf.entries:
            sys.out.println(rightAlign(e.rawSize,8) + " " + rightAlign(ZIP_COMPRESSION_METHODS[e.method],8) + " " +
                rightAlign(e.size,6) + " " + Int.toHexString(e.crc) + " " + e.name)
            rawSize = rawSize + e.rawSize
            size = size + e.size
        sys.out.println("--------          ------ -------- ----") 
        sys.out.println(rightAlign(rawSize,8) + "          " + rightAlign(size,6) + "          " + |zf.entries| + " file(s)")
        // now, extract each file    
        for e in zf.entries:
            sys.out.println("extracting " + e.name)
            rawData = zipExtract(e)
            writer = File.Writer(e.name)
            writer.write(rawData)
    catch(ZipError err):
        sys.out.println("error: " + err.msg)

string rightAlign(int val, int len):
    return rightAlign(Any.toString(val),len)

// pad out the given string to ensure it has len characters
string rightAlign(string s, int len):
    r = ""
    i = |s|
    while i < len:
        r = r + " "
        i = i + 1
    r = r + s
    return r
