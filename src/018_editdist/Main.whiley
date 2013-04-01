import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import nat from whiley.lang.Int
import * from whiley.lang.Char

(string, nat) readLine(nat pos, string input):
    start = pos
    while pos < |input| && input[pos] != '\n' && input[pos] != '\r' where pos >= 0:
        pos = pos + 1
    line = input[start..pos]
    pos = pos + 1
    if pos < |input| && (input[pos - 1] == '\r' && input[pos] == '\n'):
        pos = pos + 1
    return (line, pos)

nat skipWhiteSpace(nat index, string input) requires index >= 0, ensures $ >= 0:
    while index < |input| && isWhiteSpace(input[index]) where index >= 0:
        index = index + 1
    return index

(string, nat) getWord(nat pos, string line):
    start = pos
    while pos < |line| && !isWhiteSpace(line[pos]) where pos >= 0:
        pos = pos + 1
    word = line[start..pos]
    return (word, pos)

define Node as {nat match, int px, int py}

[[Node]] editdist_calc(string word0, string word1) requires |word0| > 0 && |word1| > 0, ensures |$| == |word1| + 1 && all {ln in $ | |ln| == |word0| + 1}:
    line = []
    i = 0
    while i <= |word0| where i >= 0:
        line = line + [{match: 0, px: -1, py: -1}]
        i = i + 1
    matrix = []
    j = 0
    while j <= |word1| where j >= 0:
        matrix = matrix + [line]
        j = j + 1

    j = 1
    while j <= |word1| where j >= 1:
        i = 1
        while i <= |word0| where i >= 1:
            match2 = matrix[j - 1][i].match
            match1 = matrix[j][i - 1].match
            match0 = matrix[j - 1][i - 1].match + 1
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

(string, string) editdist_format([[Node]] matrix, string word0, string word1) requires |word0| > 0 && |word1| > 0 && |matrix| == |word1| + 1 && all {ln in matrix | |ln| == |word0| + 1}:
    height = |matrix|
    width = |matrix[0]|
    w0 = ""
    w1 = ""
    j = height - 1
    i = width - 1
    while i > -1 && j > -1 where i < width && j < height:
        ii = matrix[j][i].px
        jj = matrix[j][i].py
        if i == 0 && j == 0:
            break
        else if i > 0 && j == 0:
            w0 = word0[0..i] + w0
            k = 0
            while k < i:
                w1 = " " + w1
                k = k + 1
        else if j > 0 && i == 0:
            k = 0
            while k < j:
                w0 = " " + w0
                k = k + 1
            w1 = word1[0..j] + w1
        else if ii == i && jj == j - 1:
            w0 = " " + w0
            w1 = word1[(j - 1)..j] + w1
        else if ii == i - 1 && jj == j:
            w0 = word0[(i - 1)..i] + w0
            w1 = " " + w1
        else if ii == i - 1 && jj == j - 1:
            w0 = word0[(i - 1)..i] + w0
            w1 = word1[(j - 1)..j] + w1
        i = ii
        j = jj

    return (w0, w1)

void ::main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: eddist <input-file>")
    else:
        file = File.Reader(sys.args[0])
        input = String.fromASCII(file.read())
        fpos = 0
        while fpos < |input| where fpos >= 0:
            line, fpos = readLine(fpos, input)
            lpos = 0
            lpos = skipWhiteSpace(lpos, line)
            word0, lpos = getWord(lpos, line)
            lpos = skipWhiteSpace(lpos, line)
            word1, lpos = getWord(lpos, line)
            if |word0| > 0 && |word1| > 0:
                matrix = editdist_calc(word0, word1)
                w0, w1 = editdist_format(matrix, word0, word1)
                sys.out.print("best match for ")
                sys.out.print(word0)
                sys.out.print(" and ")
                sys.out.print(word1)
                sys.out.println(":")
                sys.out.println("\t" + w0)
                sys.out.println("\t" + w1)
