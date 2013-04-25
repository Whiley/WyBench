import whiley.lang.*
import nat from whiley.lang.Int
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Char
import * from whiley.lang.Int
import * from whiley.lang.Byte
import * from whiley.lang.Errors
import * from whiley.io.Socket

void ::main(System.Console con):
    dat = []
    for i in 0..256:
        dat = dat + [Int.toUnsignedByte(i)]
    s = Socket.ClientSocket("127.0.0.1", 8888)
    s.write(dat)
    s.close()
    con.out.println("256 bytes are sent")
