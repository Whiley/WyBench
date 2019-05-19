import std::ascii
import std::filesystem
import std::io

import wybench::parser

type nat is (int x) where x >= 0

function gcd(nat a, nat b) -> nat:
    if(a == 0):
        return b		   
    while(b != 0) where a >= 0:
        if(a > b):
            a = a - b
        else:
            b = b - a
    return a

method main(ascii::string[] args):
    if |args| == 0:
        io::println("usage: gcd <input-file>")
    else:
        // First, parse input
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        ascii::string input = ascii::from_bytes(file.read_all())
        int[]|null data = parser::parseInts(input)
        // Second, compute gcds
        if data is null:
            io::println("error parsing input")
        else:
            nat i = 0
            while i < |data|:
                nat j = i+1
                while j < |data|:
                    if(data[i] is nat && data[j] is nat):
                        io::println(gcd(data[i],data[j]))
                    j = j + 1
                i = i + 1
            //

