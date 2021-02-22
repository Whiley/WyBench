import std::ascii
import std::filesystem with rwMode
import std::io

import wybench::parser

type nat is (int x) where x >= 0

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
// Tests
// ========================================================

method test_01():
    assume average([0]) == 0

method test_02():
    assume average([0,1]) == 0

method test_03():
    assume average([0,1,2]) == 1

method test_04():
    assume average([0,1,2,3]) == 1

method test_05():
    assume average([0,1,2,3,4]) == 2

method test_06():
    assume average([0,1,2,2,2]) == 1

method test_07():
    assume average([3,3,2,2,2]) == 2

method test_08():
    assume average([4,5,3,5,2,4,6,7,8]) == 4

