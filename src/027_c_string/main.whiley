import std::ascii
import std::io
import std::array
import nat from std::integer

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

ASCII_char NULL = 0

type C_string is (ASCII_char[] str) 
// Must have at least one character (i.e. null terminator)
where |str| > 0 && some { i in 0 .. |str| | str[i] == NULL }

// Determine the length of a C string.
public function strlen(C_string str) -> (int r)
ensures r >= 0:
    //
    nat i = 0
    //
    while str[i] != 0 
        where i < |str|
        where all { k in 0 .. i | str[k] != NULL}:
        //
        i = i + 1
    //
    return i

// Copy string from src location into destination
public method strcpy(&(ASCII_char[]) dest, C_string src)
requires |src| <= |(*dest)|:
    //
    nat i=0
    while src[i] != NULL
    where i < |src|
    where all { k in 0 .. i | src[k] != NULL}:
        (*dest)[i] = src[i]
        i = i + 1
    // Terminate new string
    (*dest)[i] = NULL
    // Done
    return
    
// Print out hello world!
public method main(ascii::string[] args):
    // ==============================================================
    // TEST: strlen
    // ==============================================================
    C_string src = ['H','e','l','l','o','W','o','r','l','d',NULL]
    io::println(strlen(src))
    
    // ==============================================================
    // TEST: strcpy
    // ==============================================================
    &C_string dest = new [1,2,3,4,5,6,7,8,9,10,11,12,13,14]
    strcpy(dest,src)
    // Check copy was correct
    assert array::equals(src,*dest,0,11)
    //
    io::println(src)
