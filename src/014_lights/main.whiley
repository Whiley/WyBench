// the British interpretation of traffic lights!
type TrafficLights is ({
    bool red,
    bool amber,
    bool green    
} t) where (!t.red && !t.amber && t.green) ||
           (!t.red && t.amber && !t.green) || // ignoring flashing
           (t.red && !t.amber && !t.green) ||
           (t.red &&  t.amber && !t.green)

TrafficLights RED = { red: true, amber: false, green: false }
TrafficLights RED_AMBER = { red: true, amber: true, green: false }
TrafficLights AMBER = { red: false, amber: true, green: false }
TrafficLights GREEN = { red: false, amber: false, green: true }

// =================================================
// Constructor
// =================================================

function TrafficLights() -> TrafficLights:
    return {
        red: true,
        amber: false,
        green: false
    }

// =================================================
// Mutator
// =================================================

function change(TrafficLights ls) -> TrafficLights:
    if ls.green:
        // -> !red && !amber && green
        return { red: false, amber: true, green: false }
    else if ls.red:
        // -> red && ~amber && !green
        if ls.amber:
            // -> red && amber && !green
            return { red: false, amber: false, green: true }
        else:
            return { red: true, amber: true, green: false }
    else:
        // -> !red && amber && !green
        return { red: true, amber: false, green: false }

// =================================================
// Tests
// =================================================

public method test_01():
    TrafficLights lights = TrafficLights()
    assume lights == RED

public method test_02():
    TrafficLights lights = TrafficLights()
    // RED -> RED AMBER
    lights = change(lights)
    //
    assume lights == RED_AMBER

public method test_03():
    TrafficLights lights = TrafficLights()
    // RED -> RED AMBER
    lights = change(lights) 
    // RED AMBER -> GREEN
    lights = change(lights)
    //
    assume lights == GREEN

public method test_04():
    TrafficLights lights = TrafficLights()
    // RED -> RED AMBER
    lights = change(lights) 
    // RED AMBER -> GREEN
    lights = change(lights)
    // GREEN -> AMBER
    lights = change(lights)    
    //
    assume lights == AMBER

public method test_05():
    TrafficLights lights = TrafficLights()
    // RED -> RED AMBER
    lights = change(lights) 
    // RED AMBER -> GREEN
    lights = change(lights)
    // GREEN -> AMBER
    lights = change(lights)
    // AMBER -> RED
    lights = change(lights)
    //
    assume lights == RED
