import whiley.lang.ASCII
import Value from Syntax

// The environment is a simple data type mapping variable names to
// their current values.

type nameValuePair is {
    ASCII.string name,
    Value value
}

constant DUMMY_PAIR is {name: "", value: 0}

public type Environment is nameValuePair[]

public function Environment() -> Environment:
    return [DUMMY_PAIR; 0]

// Get the value associated with a given variable name, or null if no
// such value exists.
public function get(Environment env, ASCII.string n) -> Value|null:
    int i = 0
    while i < |env|:
        nameValuePair p = env[i]
        if p.name == n:            
            return p.value
        i = i + 1 
    //
    return null

// Insert a new name-value pair into the environment.  If a pair
// already exists for the given variable name, then this is overwritten.
// Otherwise, a new pair is added
public function insert(Environment env, ASCII.string n, Value v) -> Environment:
    int i = 0
    while i < |env|:
        nameValuePair p = env[i]
        if p.name == n:
            env[i].value = v
            return env
        i = i + 1
    //
    Environment nEnv = [DUMMY_PAIR; |env| + 1]
    i = 0
    while i < |env|:
        nEnv[i] = env[i]
        i = i + 1
    nEnv[i] = {name: n, value: v}
    //
    return nEnv

