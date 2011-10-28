/**
 * A simplistic implementation of the Lempel-Ziv 77 compressions/decompression.
 *
 * See: http://en.wikipedia.org/wiki/LZ77_and_LZ78
 */

import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*

[byte] compress([byte] data):
    return data

[byte] decompress([byte] data):
    return data

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    data = file.read()
    sys.out.println("READ:         " + |data| + " bytes.")
    data = compress(data)
    sys.out.println("COMPRESSED:   " + |data| + " bytes.")
    data = decompress(data)
    sys.out.println("UNCOMPRESSED: " + |data| + " bytes.")
    sys.out.println("==================================")
    sys.out.print(String.fromASCII(data))



