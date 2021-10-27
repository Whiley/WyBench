import std::ascii
import nat from std::integer
import std::math

// ===============================================
// Definitions
// ===============================================

type Job is { nat button, bool orange }


function O(nat b) -> Job:
    return { button: b, orange:true }
    
function B(nat b) -> Job:
    return { button: b, orange:false }

// ===============================================
// Main Computation
// ===============================================

function process(Job[] jobs) -> nat:
    //
    int Opos = 1    // current orange position
    int Bpos = 1    // current blue position 
    int Osaved = 0  // spare time orange has saved
    int Bsaved = 0  // spare time blue has saved
    nat time = 0    // total time accumulated thus far
    // now, do the work!
    nat i = 0
    while i < |jobs| where time >= 0:
        Job job = jobs[i]
        if job.orange:
            nat diff = (nat) math::abs(job.button - Opos)
            nat timediff = (nat) math::max(0, diff - Osaved) + 1
            time = time + timediff
            Bsaved = Bsaved + timediff
            Osaved = 0
            Opos = job.button
        else:
            nat diff = (nat) math::abs(job.button - Bpos)
            nat timediff = (nat) math::max(0, diff - Bsaved) + 1
            time = time + timediff
            Osaved = Osaved + timediff
            Bsaved = 0
            Bpos = job.button
        i = i + 1
    // finally, return total time accumulated
    return time

// ===============================================
// Tests
// ===============================================

public method test_01():
    Job[] jobs = [ O(1) ]
    assume process(jobs) == 1

public method test_02():
    Job[] jobs = [ O(3) ]
    debug ascii::to_string(process(jobs))
    assume process(jobs) == 3

public method test_03():
    Job[] jobs = [ O(3),B(2) ]
    assume process(jobs) == 4

public method test_04():
    Job[] jobs = [ O(3),B(2),O(1) ]
    assume process(jobs) == 6

public method test_05():
    Job[] jobs = [ O(2),B(1),B(2),O(4) ]
    assume process(jobs) == 6

public method test_06():
    Job[] jobs = [ O(2),B(1),B(2),O(2) ]
    assume process(jobs) == 6

