// The purpose of this benchmark is to determine whether or not we can
// reason effectively about fractions without requiring a built-in
// fraction data type.

type Fraction is ({
    int numerator,
    int denominator
} fr) where fr.denominator > 0

function Fraction(int numerator, int denominator) -> (Fraction r)
requires denominator > 0
ensures (r.numerator == numerator) && (r.denominator == denominator):
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
ensures (r < 0) <==> (f1.numerator * f2.denominator) < (f2.numerator * f1.denominator)
ensures (r == 0) <==> (f1.numerator * f2.denominator) == (f2.numerator * f1.denominator)
ensures (r > 0) <==> (f1.numerator * f2.denominator) > (f2.numerator * f1.denominator):
    //
    int n1 = f1.numerator * f2.denominator
    int n2 = f2.numerator * f1.denominator
    if n1 < n2:
        return -1
    else if n1 > n2:
        return 1
    else:
        return 0

// =======================================================
// Tests
// =======================================================

public method test_01():
    Fraction f1 = Fraction(1,2) // = 1/2
    Fraction f2 = Fraction(2,4) // = 2/4
    assert compare(f1,f2) == 0

public method test_02():
    Fraction f1 = Fraction(1,2) // = 1/2
    Fraction f2 = Fraction(1,3) // = 1/3
    assert compare(f1,f2) > 0

public method test_03():
    Fraction f1 = Fraction(1,3) // = 1/3
    Fraction f2 = Fraction(1,2) // = 1/2
    assert compare(f1,f2) < 0

public method test_04():
    Fraction f1 = Fraction(1,2) // = 1/2
    Fraction f2 = Fraction(1,1) // = 1/1
    Fraction f3 = add(f1,f1)
    assert compare(f2,f3) == 0

public method test_05():
    Fraction f1 = Fraction(1,2) // = 1/2
    Fraction f2 = Fraction(1,1) // = 1/1
    Fraction f3 = add(f1,f2)
    assert compare(f1,f3) < 0
    assert compare(f2,f3) < 0    

public method test_06():
    Fraction f1 = Fraction(1,2) // = 1/2
    Fraction f2 = Fraction(1,3) // = 1/3
    Fraction f3 = add(f1,f2)
    Fraction f4 = add(f2,f1)
    assert compare(f3,f4) == 0



