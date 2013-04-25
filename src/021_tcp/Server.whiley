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
    s = Socket.ServerSocket(8888)
    cs = s.accept()
    dat = cs.read(256)
    cs.close()
    con.out.println("Received:")
    for b in dat:
        con.out.print(Byte.toUnsignedInt(b))
        con.out.print(" ")
    con.out.println("")
