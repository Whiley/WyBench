import whiley.lang.*
import whiley.io.File
import nat from whiley.lang.Int
import string from whiley.lang.ASCII

import wybench.Parser

// ===============================================
// Definitions
// ===============================================

type Job is { nat button, bool orange }
// ===============================================
// Parser
// ===============================================

constant EMPTY_JOB is { button: 0, orange: false }

function parseJobs(nat pos, string input) -> (Job[],nat):
    //
    int|null nitems
    //
    pos = Parser.skipWhiteSpace(pos,input)
    nitems,pos = Parser.parseInt(pos,input)
    if nitems != null:
        return parseNumJobs(nitems,pos,input)
    else:
        return ([EMPTY_JOB;0],pos)

function parseNumJobs(nat nitems, nat pos, string input) -> (Job[],nat):
    //
    Job[] jobs = [EMPTY_JOB; nitems]
    int|null target
    int i = 0
    //        
    while i < nitems:
        pos = Parser.skipWhiteSpace(pos,input)
        bool flag = (input[pos] == 'O')
        pos = Parser.skipWhiteSpace(pos+1,input)
        target,pos = Parser.parseInt(pos,input)
        if target != null:            
            jobs[i] = {button:target, orange: flag}
        i = i + 1
    //
    return jobs,pos
    // if nitems == 0:
    //     return ([EMPTY_JOB;0],pos)
    // else:
    //     pos = Parser.skipWhiteSpace(pos,input)
    //     if pos < |input|:
    //         int|null target, Job[] jobs
    //         bool flag = (input[pos] == 'O')
    //         pos = Parser.skipWhiteSpace(pos+1,input)
    //         target,pos = Parser.parseInt(pos,input)
    //         if target != null:
    //             jobs,pos = parseNumJobs(nitems-1,pos,input)
    //             jobs = [{button: target, orange: flag}] ++ jobs
    //             return jobs,pos        
    //     // default
    //     return ([EMPTY_JOB;0],pos)

// ===============================================
// Main Computation
// ===============================================

function processJobs(Job[] jobs) -> nat:
    //
    int Opos = 1    // current orange position
    int Bpos = 1    // current blue position 
    int Osaved = 0  // spare time orange has saved
    int Bsaved = 0  // spare time blue has saved
    int time = 0    // total time accumulated thus far
    // now, do the work!
    nat i = 0
    while i < |jobs| where time >= 0:
        Job job = jobs[i]
        if job.orange:
            int diff = Math.abs(job.button - Opos)
            int timediff = Math.max(0, diff - Osaved) + 1
            time = time + timediff
            Bsaved = Bsaved + timediff
            Osaved = 0
            Opos = job.button
        else:
            int diff = Math.abs(job.button - Bpos)
            int timediff = Math.max(0, diff - Bsaved) + 1
            time = time + timediff
            Osaved = Osaved + timediff
            Bsaved = 0
            Bpos = job.button
        i = i + 1
    // finally, return total time accumulated
    return time
            
method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("input file required!")
    else:
        // first, read the input file    
        File.Reader file = File.Reader(sys.args[0])
        string input = ASCII.fromBytes(file.readAll())
        int|null ntests, int pos = Parser.parseInt(0,input)
        if ntests != null:
            int c = 1
            Job[] jobs
            while c <= ntests where pos >= 0:
                jobs,pos = parseJobs(pos,input)
                pos = Parser.skipWhiteSpace(pos,input)
                int time = processJobs(jobs)
                sys.out.print_s("Case #")
                sys.out.print_s(Int.toString(c))
                sys.out.print_s(": ")
                sys.out.println_s(Int.toString(time))
                c = c + 1
