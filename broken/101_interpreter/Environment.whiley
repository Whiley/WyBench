import whiley.lang.ASCII
import Value from Syntax

// The environment is a simple data type mapping variable names to
// their current values.

type nameValuePair is {
    ASCII.string name,
    Value value
}

constant DUMMY_PAIR is {name: " ", value: 0}

public type Environment is nameValuePair[]

public function create() -> Environment:
    return [DUMMY_PAIR; 0]

// Get the value associated with a given variable name, or null if no
// such value exists.
public function get(Environment env, ASCII.string n) -> Value|null:
    // Check whether a key already exists for this name
    int index = indexOf(env,n)
    //
    if index < |env|:
        // match found
        return env[index].value
    else:
        // no match
        return null

// Insert a new name-value pair into the environment.  If a pair
// already exists for the given variable name, then this is overwritten.
// Otherwise, a new pair is added
public function insert(Environment env, ASCII.string n, Value v) -> Environment:
    // Check whether a key already exists for this name
    int index = indexOf(env,n)
    //
    if index < |env|:
        // Yes, it does.  Update entry in place.
        env[index].value = v
        return env
    else:
        // No, it doesn't.  Create space for new entry.
        Environment nEnv = [DUMMY_PAIR; |env| + 1]
        nEnv = copy(env,nEnv)
        // Copy entry into new space
        nEnv[index] = {name: n, value: v}
        //
        return nEnv

private function indexOf(Environment env, ASCII.string n) -> (int r):
    //
    int i = 0
    // Check whether a key already exists for this name
    while i < |env|:
        nameValuePair p = env[i]
        if p.name == n:
            return i
        i = i + 1
    //
    return i

// Should eventually be replaced with Array.copy
private function copy(Environment src, Environment dest) -> (Environment r):
    //
    int i = 0
    while i < |src|:
        dest[i] = src[i]
        i = i + 1
    //
    return dest