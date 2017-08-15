import std::filesystem
import std::io

import char from std::ascii
import string from std::ascii
import nat from std::integer

import wybench::parser

// ========================================================
// Benchmark
// ========================================================

function average(int[] data) -> int
// Input list cannot be empty
requires |data| > 0:
    //
    int sum = 0
    nat i = 0
    while i < |data|:
        sum = sum + data[i]
        i = i + 1
    return sum / |data|

// ========================================================
// Main
// ========================================================

method main(ascii::string[] args):
    if |args| == 0:
        io::println("usage: average <file>")
    else:
        // first, read the input data
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        string input = ascii::fromBytes(file.readAll())
        int[]|null data = parser::parseInts(input)
        // second, run the benchmark
        if data is null:
            io::println("error parsing input")
        else if |data| == 0:
            io::println("no data provided!")
        else:
            int avg = average(data)
            io::println(avg)
