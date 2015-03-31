import whiley.lang.*
import * from whiley.io.File
import nat from whiley.lang.Int
import * from whiley.lang.Char

function readLine(nat pos, string input) -> (string, nat):
    int start = pos
    while pos < |input| && input[pos] != '\n' && input[pos] != '\r' where pos >= 0:
        pos = pos + 1
    string line = input[start..pos]
    pos = pos + 1
    if pos < |input| && (input[pos - 1] == '\r' && input[pos] == '\n'):
        pos = pos + 1
    return (line, pos)

function skipWhiteSpace(nat index, string input) -> nat:
    while index < |input| && isWhiteSpace(input[index]) where index >= 0:
        index = index + 1
    return index

function getWord(nat pos, string line) -> (string, nat):
    int start = pos
    while pos < |line| && !isWhiteSpace(line[pos]) where pos >= 0:
        pos = pos + 1
    string word = line[start..pos]
    return (word, pos)

type Node is {nat match, int px, int py}

function editdist_calc(string word0, string word1) -> ([[Node]] result)
requires |word0| > 0 && |word1| > 0
ensures |result| == |word1| + 1 && all {ln in result | |ln| == |word0| + 1}:
    //
    [Node] line = []
    int i = 0
    while i <= |word0| where i >= 0:
        line = line ++ [{match: 0, px: -1, py: -1}]
        i = i + 1
    [[Node]] matrix = []
    int j = 0
    while j <= |word1| where j >= 0:
        matrix = matrix ++ [line]
        j = j + 1

    j = 1
    while j <= |word1| where j >= 1:
        i = 1
        while i <= |word0| where i >= 1:
            int match2 = matrix[j - 1][i].match
            int match1 = matrix[j][i - 1].match
            int match0 = matrix[j - 1][i - 1].match + 1
            if word0[i - 1] == word1[j - 1] && match0 >= match1 && match0 >= match2:
                matrix[j][i].match = match0
                matrix[j][i].px = i - 1
                matrix[j][i].py = j - 1
            else if match2 > match1:
                matrix[j][i].match = match2
                matrix[j][i].px = i
                matrix[j][i].py = j - 1
            else:
                matrix[j][i].match = match1
                matrix[j][i].px = i - 1
                matrix[j][i].py = j
            i = i + 1
        j = j + 1

    return matrix

function editdist_format([[Node]] matrix, string word0, string word1) -> (string, string) 
requires |word0| > 0 && |word1| > 0 && |matrix| == |word1| + 1 && all {ln in matrix | |ln| == |word0| + 1}:
    //
    int height = |matrix|
    int width = |matrix[0]|
    string w0 = ""
    string w1 = ""
    int j = height - 1
    int i = width - 1
    while i > -1 && j > -1 where i < width && j < height:
        int ii = matrix[j][i].px
        int jj = matrix[j][i].py
        if i == 0 && j == 0:
            break
        else if i > 0 && j == 0:
            w0 = word0[0..i] ++ w0
            int k = 0
            while k < i:
                w1 = " " ++ w1
                k = k + 1
        else if j > 0 && i == 0:
            int k = 0
            while k < j:
                w0 = " " ++ w0
                k = k + 1
            w1 = word1[0..j] ++ w1
        else if ii == i && jj == j - 1:
            w0 = " " ++ w0
            w1 = word1[(j - 1)..j] ++ w1
        else if ii == i - 1 && jj == j:
            w0 = word0[(i - 1)..i] ++ w0
            w1 = " " ++ w1
        else if ii == i - 1 && jj == j - 1:
            w0 = word0[(i - 1)..i] ++ w0
            w1 = word1[(j - 1)..j] ++ w1
        i = ii
        j = jj

    return (w0, w1)

method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: eddist <input-file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        string input = String.fromASCII(file.readAll())
        string line, string word0, string word1
        int fpos = 0
        while fpos < |input| where fpos >= 0:
            line, fpos = readLine(fpos, input)
            int lpos = skipWhiteSpace(0, line)
            word0, lpos = getWord(lpos, line)
            lpos = skipWhiteSpace(lpos, line)
            word1, lpos = getWord(lpos, line)
            if |word0| > 0 && |word1| > 0:
                [[Node]] matrix = editdist_calc(word0, word1)
                string w0, string w1 = editdist_format(matrix, word0, word1)
                sys.out.print("best match for ")
                sys.out.print(word0)
                sys.out.print(" and ")
                sys.out.print(word1)
                sys.out.println(":")
                sys.out.println("\t" ++ w0)
                sys.out.println("\t" ++ w1)
