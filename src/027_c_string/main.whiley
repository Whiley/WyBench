import std::ascii
import std::array
import uint from std::integer

//
// This little example is showing off an almost complete encoding
// of C strings as constrained lists of ints in Whiley.  The key 
// requirements are that the list contains only ASCII characters, 
// and that it is null terminated.
//
// The only outstanding problem with this encoding is that it embeds 
// the list size (i.e. there is currently no way to get rid of this).
//
type ASCII_char is (int n) where 0 <= n && n <= 255

// Definte null terminator
ASCII_char NULL = 0

type C_string_data is (ASCII_char[] chars)
// Must have at least one character (i.e. null terminator)
where |chars| > 0 && some { i in 0 .. |chars| | chars[i] == NULL }

type C_string is &{C_string_data chars}

// Determine the length of a C string.
method strlen(C_string str) -> (uint r)
// Length defined by NULL terminator
ensures str->chars[r] == NULL
// No other NULL terminators
ensures all { k in 0..r | str->chars[k] != NULL }:
    //
    uint i = 0
    //
    while str->chars[i] != NULL
    where i < |str->chars|
    where all { k in 0 .. i | str->chars[k] != NULL}:
        //
        i = i + 1
    //
    return i

// Copy string from src location into destination
method strcpy(C_string dest, C_string src)
requires |src->chars| <= |dest->chars|:
    //
    uint i = 0
    while src->chars[i] != NULL
    where i < |src->chars|
    where all { k in 0 .. i | src->chars[k] != NULL}:
        dest->chars[i] = src->chars[i]
        i = i + 1
    // Terminate new string
    dest->chars[i] = NULL
    // Done
    return

// =======================================================
// Tests
// =======================================================

public method test_01():
    C_string src = new {chars: [NULL]}
    int n = strlen(src)
    assert n == 0

public method test_02():
    C_string src = new {chars: [NULL,NULL]}
    int n = strlen(src)
    assert n == 0

public method test_03():
    C_string src = new {chars: [NULL,0]}
    int n = strlen(src)
    assert n == 0

public method test_04():
    C_string src = new {chars: ['H','e','l','l','o','W','o','r','l','d',NULL]}
    int n = strlen(src)
    assert n == 10
