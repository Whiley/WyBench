import std::array
import std::ascii
import std::io

// the British interpretation of traffic lights!
type TrafficLights is ({
    bool red,
    bool amber,
    bool green    
} t) where (!t.red && !t.amber && t.green) ||
           (!t.red && t.amber && !t.green) || // ignoring flashing
           (t.red && !t.amber && !t.green) ||
           (t.red &&  t.amber && !t.green)

function TrafficLights() -> TrafficLights:
    return {
        red: true,
        amber: false,
        green: false
    }

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

function toString(TrafficLights ls) -> ascii::string:
    ascii::string r
    //
    if ls.red:
        r = "RED "
    else:
        r = "    "
    if ls.amber:
        r = ascii::append(r,"AMBER ")
    else:
        r = ascii::append(r,"       ")
    if ls.green:
        r = ascii::append(r,"GREEN ")
    else:
        r = ascii::append(r,"      ")
    return r

public method main(ascii::string[] args):
    TrafficLights lights = TrafficLights()
    io::println(toString(lights))
    lights = change(lights)
    io::println(toString(lights))
    lights = change(lights)
    io::println(toString(lights))
    lights = change(lights)
    io::println(toString(lights))
    lights = change(lights)
    io::println(toString(lights))
