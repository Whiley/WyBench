import std.ascii
import std.io

// The purpose of this benchmark is to determine whether or not we can
// reason effectively about fractions without requiring a built-in
// fraction data type.

type Fraction is ({
    int numerator,
    int denominator
} fr) where fr.denominator > 0

function Fraction(int numerator, int denominator) -> (Fraction r)
requires denominator > 0
ensures r.numerator == numerator && r.denominator == denominator:
    return { numerator: numerator, denominator: denominator }

/**
 * Add two fractions together.  This doesn't perform any kind of simplification though!
 */
function add(Fraction f1, Fraction f2) -> (Fraction f3)
ensures f3.numerator == ((f1.numerator * f2.denominator) + (f2.numerator * f1.denominator))
ensures f3.denominator == (f1.denominator * f2.denominator):
    //
    return {
        numerator: (f1.numerator * f2.denominator) + (f2.numerator * f1.denominator),
        denominator:  (f1.denominator * f2.denominator)
    }

/**
 * Check whether two fractions are equal or not.
 */
function compare(Fraction f1, Fraction f2) -> (int r)
ensures r < 0 <==> (f1.numerator * f2.denominator) < (f2.numerator * f1.denominator)
ensures r == 0 <==> (f1.numerator * f2.denominator) == (f2.numerator * f1.denominator)
ensures r > 0 <==> (f1.numerator * f2.denominator) < (f2.numerator * f1.denominator):
    //
    int n1 = f1.numerator * f2.denominator
    int n2 = f2.numerator * f1.denominator
    if n1 < n2:
        return -1
    else if n1 > n2:
        return 1
    else:
        return 0

// Some simple test methods
method main(ascii.string[] args):
    Fraction f1 = Fraction(1,2) // = 1/2
    Fraction f2 = Fraction(2,4) // = 2/4
    assert compare(f1,f2) == 0
    Fraction f3 = Fraction(1,1)
    assert compare(f1,f3) < 0
    assert compare(f3,f1) > 0        
    Fraction f4 = add(f1,f1) // 1/1
    assert compare(f3,f4) == 0



