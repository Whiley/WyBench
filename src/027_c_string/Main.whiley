import whiley.lang.System

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

type C_string is ([ASCII_char] chars) 
// Must have at least one character (i.e. null terminator)
where |chars| > 0 && chars[|chars|-1] == 0

// Determine the length of a C string.
public function strlen(C_string str) -> (int r)
ensures r >= 0:
    //
    int i = 0
    //
    while str[i] != 0 
        where i >= 0 && i < |str|
        where str[i] != 0 ==> (i+1) < |str|:
        //
        i = i + 1
    //
    return i

// Copy string from src location into destination
public method strcpy(&C_string dest, C_string src)
requires |src| <= |(*dest)|:
    //
    int i=0
    while src[i] != 0:
        (*dest)[i] = src[i]
        i = i + 1
    //
    return
    
// Print out hello world!
public method main(System.Console console):
    // ==============================================================
    // TEST: strlen
    // ==============================================================
    C_string src = ([int]) ['H','e','l','l','o','W','o','r','l','d',0]
    console.out.println(strlen(src))
    
    // ==============================================================
    // TEST: strcpy
    // ==============================================================
    &C_string dest = new [1,2,3,4,5,6,7,8,9,10,11,12,13,14]
    strcpy(dest,src)
    console.out.println_s(src)