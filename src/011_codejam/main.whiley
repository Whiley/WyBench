import std::ascii
import std::filesystem
import nat from std::integer
import std::io
import std::math

import wybench::parser

// ===============================================
// Definitions
// ===============================================

type Job is { nat button, bool orange }
// ===============================================
// Parser
// ===============================================

Job EMPTY_JOB = { button: 0, orange: false }

function parseJobs(nat pos, ascii::string input) -> (Job[] jobs, nat npos):
    //
    int|null nitems
    //
    pos = parser::skipWhiteSpace(pos,input)
    nitems,pos = parser::parseInt(pos,input)
    if nitems is int:
        return parseNumJobs(nitems,pos,input)
    else:
        return [EMPTY_JOB;0],pos

function parseNumJobs(nat nitems, nat pos, ascii::string input) -> (Job[] jobs, nat npos):
    //
    Job[] js = [EMPTY_JOB; nitems]
    int|null target
    int i = 0
    //        
    while i < nitems:
        pos = parser::skipWhiteSpace(pos,input)
        bool flag = (input[pos] == 'O')
        pos = parser::skipWhiteSpace(pos+1,input)
        target,pos = parser::parseInt(pos,input)
        if target is int:
            js[i] = {button:target, orange: flag}
        i = i + 1
    //
    return js,pos
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
            int diff = math::abs(job.button - Opos)
            int timediff = math::max(0, diff - Osaved) + 1
            time = time + timediff
            Bsaved = Bsaved + timediff
            Osaved = 0
            Opos = job.button
        else:
            int diff = math::abs(job.button - Bpos)
            int timediff = math::max(0, diff - Bsaved) + 1
            time = time + timediff
            Osaved = Osaved + timediff
            Bsaved = 0
            Bpos = job.button
        i = i + 1
    // finally, return total time accumulated
    return time
            
method main(ascii::string[] args):
    if |args| == 0:
        io::println("input file required!")
    else:
        int pos
        int|null ntests
        // first, read the input file    
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        ascii::string input = ascii::fromBytes(file.readAll())
        ntests,pos = parser::parseInt(0,input)
        //
        if ntests is int:
            int c = 1
            Job[] jobs
            while c <= ntests where pos >= 0:
                jobs,pos = parseJobs(pos,input)
                pos = parser::skipWhiteSpace(pos,input)
                int time = processJobs(jobs)
                io::print("Case #")
                io::print(c)
                io::print(": ")
                io::println(time)
                c = c + 1
