import char,string from std::ascii
import uint from std::integer

// match: search for regexp anywhere in text
function match(string regex, string text) -> bool:
    if |regex| > 0 && regex[0] == '^':
        return matchHere(regex,1,text,0)
    if matchHere(regex,0,text,0):
        return true
    uint i = 0
    while i < |text|:
        if matchHere(regex,0,text,i):
            return true
        else:
            i = i + 1
    return false

// matchHere: search for regex at beginning of text
function matchHere(string regex, uint rIndex, string text, uint tIndex) -> bool
requires rIndex <= |regex|:
    if rIndex == |regex|:
        return true
    else if (rIndex+1) < |regex| && regex[rIndex+1] == '*':
        return matchStar(regex[rIndex],regex,rIndex+2,text,tIndex)
    else if rIndex + 1 == |regex| && regex[rIndex] == '$':
        return tIndex == |text|
    else if tIndex < |text| && (regex[rIndex]=='.' || regex[rIndex] == text[tIndex]):
        return matchHere(regex,rIndex+1,text,tIndex+1)
    else:
        return false

// matchstar: search for c*regex at beginning of text
function matchStar(char c, string regex, uint rIndex, string text, uint tIndex) -> bool
requires rIndex <= |regex|:
    // first, check for zero matches
    if matchHere(regex,rIndex,text,tIndex):
        return true
    // second, check for one or more matches
    while tIndex < |text| && (text[tIndex] == c || c == '.'):
        if matchHere(regex,rIndex,text,tIndex):    
            return true
        else:
            tIndex = tIndex + 1
    if matchHere(regex,rIndex,text,tIndex):
        return true
    return false

// ==========================================================
// Tests
// ==========================================================

public method test_1():
    assume !match("a","b")

public method test_2():
    assume !match("b","a")

public method test_3():
    assume !match("d","1")

public method test_4():
    assume !match("abcxyx","abcxyz")

public method test_5():
    assume match(".","b")

public method test_6():
    assume match(".","aa")

public method test_7():
    assume !match("....","abc")

public method test_8():
    assume match("..","abc")

public method test_9():
    assume !match("acb.yz","abcxyz")

public method test_10():
    assume match("b*","a")

public method test_11():
    assume match("ab*","abc")

public method test_12():
    assume match("a*c","abc")

public method test_13():
    assume !match("a.*yx","abcxyz")

public method test_14():
    assume !match(".*abxyz","abcxyz")

public method test_15():
    assume match("abcz*","abcxyz")

public method test_16():
    assume !match("^a","ba")

public method test_17():
    assume !match("a$","ab")

public method test_18():
    assume !match("^a$","ba")

public method test_19():
    assume !match("^a$","ab")

public method test_20():
    assume !match("^abcxyz","aabcxyz")

public method test_21():
    assume !match("abcxyz$","abcxyzz")

public method test_22():
    assume !match("^abcxyz$","aabcxyz")

public method test_23():
    assume !match("^abcxyz$","abcxyzz")

public method test_24():
    assume !match("^abc","aabcxyz")

public method test_25():
    assume !match("xyz$","abcxyzz")

public method test_26():
    assume match("^.","x")

public method test_27():
    assume match(".$","x")

public method test_28():
    assume match("^.$","x")

public method test_29():
    assume !match("^a*$","b")

public method test_30():
    assume !match("^aa*","ba")

public method test_31():
    assume !match("aa*$","ab")

public method test_32():
    assume !match("^aa*$","ab")

public method test_33():
    assume !match("^ab.*","aabcxyz")

public method test_34():
    assume !match("ab.*c$","abcxyz")

public method test_35():
    assume !match("^ab.*$","aabcxyz")

public method test_36():
    assume match("^ab.*$","abcxyzz")

public method test_37():
    assume !match(".*xy$","abcxyz")

public method test_38():
    assume !match("^.*xy$","abcxyz")

public method test_39():
    assume !match("a","x")

public method test_40():
    assume !match("a","x")

public method test_41():
    assume match("abc","abc")

public method test_42():
    assume match("abcxyz","abcxyz")

public method test_43():
    assume match(".","a")

public method test_44():
    assume match(".","z")

public method test_45():
    assume match("...","abc")

public method test_46():
    assume match("......","abcxyz")

public method test_47():
    assume match(".*","x")

public method test_48():
    assume match(".*","a")

public method test_49():
    assume match(".*","abc")

public method test_50():
    assume match(".*","abcxyz")

public method test_51():
    assume match(".*.*","x")

public method test_52():
    assume match(".*.*","a")

public method test_53():
    assume match(".*.*","abc")

public method test_54():
    assume match(".*.*","abcxyz")

public method test_55():
    assume match(".*.*.*.*.*.*.*.*","x")

public method test_56():
    assume match(".*.*.*.*.*.*.*.*","a")

public method test_57():
    assume match(".*.*.*.*.*.*.*.*","abc")

public method test_58():
    assume match(".*.*.*.*.*.*.*.*","abcxyz")

public method test_59():
    assume match(".*..","abc")

public method test_60():
    assume match(".*.","abcxyz")

public method test_61():
    assume match(".*.","abc")

public method test_62():
    assume match(".*..","abcxyz")

public method test_63():
    assume match(".*...","abc")

public method test_64():
    assume match(".*...","abcxyz")

public method test_65():
    assume match(".*..*..","abcxyz")

public method test_66():
    assume match(".*..*..*","abcxyz")

public method test_67():
    assume match("^","x")

public method test_68():
    assume !match("$","x")

public method test_69():
    assume !match("^$","x")

public method test_70():
    assume match("^a","a")

public method test_71():
    assume match("a$","a")

public method test_72():
    assume match("^a$","a")

public method test_73():
    assume match("^abcxyz","abcxyz")

public method test_74():
    assume match("abcxyz$","abcxyz")

public method test_75():
    assume match("^abcxyz$","abcxyz")

public method test_76():
    assume match("^abc","abcxyz")

public method test_77():
    assume match("xyz$","abcxyz")

public method test_78():
    assume match("^.","a")

public method test_79():
    assume match(".$","a")

public method test_80():
    assume match("^.$","a")

public method test_81():
    assume match("^.*","x")

public method test_82():
    assume match(".*$","x")

public method test_83():
    assume match("^.*$","x")

public method test_84():
    assume !match("^a*$","x")

public method test_85():
    assume match("^.*","a")

public method test_86():
    assume match(".*$","a")

public method test_87():
    assume match("^.*$","a")

public method test_88():
    assume match("^a*$","a")

public method test_89():
    assume match("^aa*","a")

public method test_90():
    assume match("aa*$","a")

public method test_91():
    assume match("^aa*$","a")

public method test_92():
    assume match("^a*a","a")

public method test_93():
    assume match("a*a$","a")

public method test_94():
    assume match("^a*a$","a")

public method test_95():
    assume match("^ab.*","abcxyz")

public method test_96():
    assume match("ab.*$","abcxyz")

public method test_97():
    assume match("^ab.*$","abcxyz")

public method test_98():
    assume match("^.*xy","abcxyz")

public method test_99():
    assume match(".*xyz$","abcxyz")

public method test_100():
    assume match("^.*xyz$","abcxyz")

