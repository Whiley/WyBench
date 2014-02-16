import whiley.lang.*
import nat from whiley.lang.Int
import * from whiley.io.File
import * from whiley.lang.Char
import * from whiley.lang.Errors

function readLine(nat pos, string input) => (string, nat):
    int start = pos
    while pos < |input| && input[pos] != '\n' && input[pos] != '\r' where pos >= 0:
        pos = pos + 1
    string line = input[start..pos]
    pos = pos + 1
    if pos < |input| && (input[pos - 1] == '\r' && input[pos] == '\n'):
        pos = pos + 1
    return (line, pos)

function skipWhiteSpace(nat index, string input) => nat
requires index >= 0:
    //
    while index < |input| && isWhiteSpace(input[index]) where index >= 0:
        index = index + 1
    return index

function parseInt(nat pos, string input) => (nat, int) 
throws SyntaxError:
    //
    int start = pos
    // check for negative input
    if pos < |input| && input[pos] == '-': 
        pos = pos + 1
    // match remainder
    while pos < |input| && Char.isDigit(input[pos]) where pos >= 0:
        pos = pos + 1
    // check for error
    if pos == start:
        throw SyntaxError("invalid number", start, pos)
    // done
    return (Int.parse(input[start..pos]), pos)

function max_({nat} s) => (nat r)
// Argument set cannot be empty
requires |s| > 0
// Return value must be one of argument set
ensures r in s:
    //
    int j = -1
    for i in s:
        if i > j:
            j = i
    return j

function subseq([int] seq) => ({nat} r)
requires |seq| > 0
ensures |r| > 0:
    //
    [{nat}] res = [{0}]
    int i = 1
    while i < |seq| where i >= 1:
        int j = i - 1
        while j >= 0 where j <= i - 1:
            if seq[j] < seq[i]:
                break
            j = j - 1
        if j < 0:
            res = res ++ [{i}]
        else:
            int k = 0
            int h = -1
            {int} t = {}
            int r = -1
            while k < i where k >= 0:
                int hh, int tt
                if seq[max_(res[k])] < seq[i]:
                    hh = |res[k]| + 1
                    tt = res[k] + {i}
                else:
                    hh = |res[k]|
                    tt = res[k]
                if hh > h:
                    h = hh
                    t = tt
                    r = k
                k = k + 1
            assert |t| > 1
            res = res ++ [t]
        i = i + 1

    return res[|seq| - 1]

method main(System.Console con):
    if |con.args| == 0:
        con.out.println("usage: subseq <input-file>")
    else:
        File.Reader file = File.Reader(con.args[0])
        string input = String.fromASCII(file.readAll())
        string line
        int fpos = 0
        while fpos < |input| where fpos >= 0:
            line, fpos = readLine(fpos, input)
            try:
                int lpos = 0
                int val
                [int] seq = []
                while lpos < |line| where lpos >= 0:
                    val, lpos = parseInt(lpos, line)
                    seq = seq ++ [val]
                    lpos = skipWhiteSpace(lpos, line)
                if |seq| > 0:
                    {int} sub = subseq(seq)
                    int i = 0
                    while i < |seq| where i >= 0:
                        if i in sub:
                            con.out.print("(")
                        con.out.print(seq[i])
                        if i in sub:
                            con.out.print(")")
                        con.out.print(" ")
                        i = i + 1
                    con.out.println("")
            catch(SyntaxError e):
                con.out.println("error - " ++ e.msg)

