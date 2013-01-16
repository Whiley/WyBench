import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

// ===============================================
// Definitions
// ===============================================

define Job as { nat button, bool orange }

// ===============================================
// Parser
// ===============================================

([Job],nat) parseJobs(nat pos, string input) throws SyntaxError:
    nitems,pos = parseInt(pos,input)
    return parseJobs(nitems,pos,input)

([Job],nat) parseJobs(nat nitems, nat pos, string input) throws SyntaxError:
    if nitems == 0:
        return ([],pos)
    else:
        pos = skipWhiteSpace(pos,input)
        if pos < |input|:
            flag = (input[pos] == 'O')
            pos = skipWhiteSpace(pos+1,input)
            target,pos = parseInt(pos,input)
            jobs,pos = parseJobs(nitems-1,pos,input)
            jobs = [{button: target, orange: flag}] + jobs
            return jobs,pos        
        else:
            throw SyntaxError("Missing flag",pos,pos)        

(nat,nat) parseInt(nat pos, string input) throws SyntaxError:
    pos = skipWhiteSpace(pos,input)
    start = pos
    while pos < |input| && Char.isDigit(input[pos]) where pos >= 0:
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    val = Math.abs(Int.parse(input[start..pos]))
    return val,pos

nat skipWhiteSpace(nat index, string input):
    while index < |input| && isWhiteSpace(input[index]) where index >= 0:
        index = index + 1
    return index

// ===============================================
// Main Computation
// ===============================================

nat processJobs([Job] jobs):
    Opos = 1    // current orange position
    Bpos = 1    // current blue position 
    Osaved = 0  // spare time orange has saved
    Bsaved = 0  // spare time blue has saved
    time = 0    // total time accumulated thus far
    // now, do the work!
    for j in jobs where time >= 0:
        if j.orange:
            diff = Math.abs(j.button - Opos)
            timediff = Math.max(0, diff - Osaved) + 1
            time = time + timediff
            Bsaved = Bsaved + timediff
            Osaved = 0
            Opos = j.button
        else:
            diff = Math.abs(j.button - Bpos)
            timediff = Math.max(0, diff - Bsaved) + 1
            time = time + timediff
            Osaved = Osaved + timediff
            Bsaved = 0
            Bpos = j.button
    // finally, return total time accumulated
    return time
            
void ::main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("input file required!")
    else:
        // first, read the input file    
        file = File.Reader(sys.args[0])
        input = String.fromASCII(file.read())
        try:
            ntests,pos = parseInt(0,input)
            c = 1
            while c <= ntests where pos >= 0:
                jobs,pos = parseJobs(pos,input)
                pos = skipWhiteSpace(pos,input)
                time = processJobs(jobs)
                sys.out.println("Case #" + c + ": " + time)
                c = c + 1
        catch(SyntaxError e):
            sys.out.println("error - " + e.msg)
