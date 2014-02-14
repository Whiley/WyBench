import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

// ===============================================
// Definitions
// ===============================================

type Job is { nat button, bool orange }

// ===============================================
// Parser
// ===============================================

function parseJobs(nat pos, string input) => ([Job],nat) 
throws SyntaxError:
    //
    int nitems
    nitems,pos = parseInt(pos,input)
    return parseJobs(nitems,pos,input)

function parseJobs(nat nitems, nat pos, string input) => ([Job],nat) 
throws SyntaxError:
    //
    if nitems == 0:
        return ([],pos)
    else:
        pos = skipWhiteSpace(pos,input)
        if pos < |input|:
            int target, [Job] jobs
            bool flag = (input[pos] == 'O')
            pos = skipWhiteSpace(pos+1,input)
            target,pos = parseInt(pos,input)
            jobs,pos = parseJobs(nitems-1,pos,input)
            jobs = [{button: target, orange: flag}] ++ jobs
            return jobs,pos        
        else:
            throw SyntaxError("Missing flag",pos,pos)        

function parseInt(nat pos, string input) => (nat,nat)
throws SyntaxError:
    //
    pos = skipWhiteSpace(pos,input)
    int start = pos
    while pos < |input| && Char.isDigit(input[pos]) where pos >= 0:
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    int val = Math.abs(Int.parse(input[start..pos]))
    return val,pos

function skipWhiteSpace(nat index, string input) => nat:
    //
    while index < |input| && isWhiteSpace(input[index]) where index >= 0:
        index = index + 1
    return index

// ===============================================
// Main Computation
// ===============================================

function processJobs([Job] jobs) => nat:
    //
    int Opos = 1    // current orange position
    int Bpos = 1    // current blue position 
    int Osaved = 0  // spare time orange has saved
    int Bsaved = 0  // spare time blue has saved
    int time = 0    // total time accumulated thus far
    // now, do the work!
    for j in jobs where time >= 0:
        if j.orange:
            int diff = Math.abs(j.button - Opos)
            int timediff = Math.max(0, diff - Osaved) + 1
            time = time + timediff
            Bsaved = Bsaved + timediff
            Osaved = 0
            Opos = j.button
        else:
            int diff = Math.abs(j.button - Bpos)
            int timediff = Math.max(0, diff - Bsaved) + 1
            time = time + timediff
            Osaved = Osaved + timediff
            Bsaved = 0
            Bpos = j.button
    // finally, return total time accumulated
    return time
            
method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("input file required!")
    else:
        // first, read the input file    
        File.Reader file = File.Reader(sys.args[0])
        string input = String.fromASCII(file.readAll())
        try:
            int ntests, int pos = parseInt(0,input)
            int c = 1
            [Job] jobs
            while c <= ntests where pos >= 0:
                jobs,pos = parseJobs(pos,input)
                pos = skipWhiteSpace(pos,input)
                int time = processJobs(jobs)
                sys.out.println("Case #" ++ c ++ ": " ++ time)
                c = c + 1
        catch(SyntaxError e):
            sys.out.println("error - " ++ e.msg)
