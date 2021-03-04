import std::array
import std::ascii

final month JAN = 1
final month FEB = 2
final month MAR = 3
final month APR = 4
final month MAY = 5
final month JUN = 6
final month JUL = 7
final month AUG = 8
final month SEP = 9
final month OCT = 10
final month NOV = 11
final month DEC = 12

type day is (int d) where 1 <= d && d <= 31
type month is (int x) where 1 <= x && x <= 12

// =================================================
// Date
// =================================================

type Date is ({
    day day,
    month month,
    int year
} d) where (d.day <= 30 || (d.month != SEP && d.month != APR && d.month != JUN && d.month != NOV)) &&
        (d.month != FEB || d.day <= 29 ) &&
        (d.month != FEB || d.year % 4 != 0 || (d.year % 100 == 0 && d.year % 400 != 0) || d.day <= 28) // leap-year restriction

// =================================================
// Constructor
// =================================================

function Date(day day, month month, int year) -> Date
// 30 days hath September, April, June and November.
requires day <= 30 || (month != SEP && month != APR && month != JUN && month != NOV)
// All the rest have 31, except Februrary
requires month != FEB || day <= 29
// Which has 29, but 28 in a leap year
requires month != FEB || year % 4 != 0 || (year % 100 == 0 && year % 400 != 0) || day <= 28:
    //
    return {
        day: day,
        month: month,
        year: year
    }

// =================================================
// Mutator
// =================================================

// Compute the date of the next day.
function next(Date date) -> Date:
    // first, calculate last day of the month
    int last
    switch date.month:
        case FEB:
            last = 29
        case SEP,APR,JUN,NOV:
            last = 30
        default:
            last = 31
    // second, calculate date of next day
    if date.day == last:
        date.day = 1
        if date.month == DEC:
            date.year = date.year + 1
            date.month = JAN
        else:
            date.month = date.month + 1
    else:
        date.day = date.day + 1
    // done
    return date

// =================================================
// Test Cases
// =================================================
public method test_0():
    assume next(Date(1,JAN,1996)) == Date(2,JAN,1996)

public method test_1():
    assume next(Date(4,FEB,1996)) == Date(5,FEB,1996)

public method test_2():
    assume next(Date(24,FEB,1996)) == Date(25,FEB,1996)

public method test_3():
    assume next(Date(23,MAR,1996)) == Date(24,MAR,1996)

public method test_4():
    assume next(Date(11,APR,1996)) == Date(12,APR,1996)

public method test_5():
    assume next(Date(15,MAY,1996)) == Date(16,MAY,1996)

public method test_6():
    assume next(Date(4,JUN,1996)) == Date(5,JUN,1996)

public method test_7():
    assume next(Date(16,JUN,1996)) == Date(17,JUN,1996)

public method test_8():
    assume next(Date(22,JUL,1996)) == Date(23,JUL,1996)

public method test_9():
    assume next(Date(27,AUG,1996)) == Date(28,AUG,1996)

public method test_10():
    assume next(Date(1,OCT,1996)) == Date(2,OCT,1996)

public method test_11():
    assume next(Date(22,OCT,1996)) == Date(23,OCT,1996)

public method test_12():
    assume next(Date(25,OCT,1996)) == Date(26,OCT,1996)

public method test_13():
    assume next(Date(29,NOV,1996)) == Date(30,NOV,1996)

public method test_14():
    assume next(Date(17,JAN,1997)) == Date(18,JAN,1997)

public method test_15():
    assume next(Date(27,JAN,1997)) == Date(28,JAN,1997)

public method test_16():
    assume next(Date(1,MAR,1997)) == Date(2,MAR,1997)

public method test_17():
    assume next(Date(16,MAR,1997)) == Date(17,MAR,1997)

public method test_18():
    assume next(Date(21,MAR,1997)) == Date(22,MAR,1997)

public method test_19():
    assume next(Date(23,APR,1997)) == Date(24,APR,1997)

public method test_20():
    assume next(Date(29,APR,1997)) == Date(30,APR,1997)

public method test_21():
    assume next(Date(7,MAY,1997)) == Date(8,MAY,1997)

public method test_22():
    assume next(Date(6,JUN,1997)) == Date(7,JUN,1997)

public method test_23():
    assume next(Date(10,JUL,1997)) == Date(11,JUL,1997)

public method test_24():
    assume next(Date(7,AUG,1997)) == Date(8,AUG,1997)

public method test_25():
    assume next(Date(15,SEP,1997)) == Date(16,SEP,1997)

public method test_26():
    assume next(Date(20,OCT,1997)) == Date(21,OCT,1997)

public method test_27():
    assume next(Date(9,NOV,1997)) == Date(10,NOV,1997)

public method test_28():
    assume next(Date(19,DEC,1997)) == Date(20,DEC,1997)

public method test_29():
    assume next(Date(25,JAN,1998)) == Date(26,JAN,1998)

public method test_30():
    assume next(Date(9,MAR,1998)) == Date(10,MAR,1998)

public method test_31():
    assume next(Date(11,APR,1998)) == Date(12,APR,1998)

public method test_32():
    assume next(Date(17,MAY,1998)) == Date(18,MAY,1998)

public method test_33():
    assume next(Date(14,JUN,1998)) == Date(15,JUN,1998)

public method test_34():
    assume next(Date(26,JUN,1998)) == Date(27,JUN,1998)

public method test_35():
    assume next(Date(6,AUG,1998)) == Date(7,AUG,1998)

public method test_36():
    assume next(Date(7,SEP,1998)) == Date(8,SEP,1998)

public method test_37():
    assume next(Date(25,SEP,1998)) == Date(26,SEP,1998)

public method test_38():
    assume next(Date(22,OCT,1998)) == Date(23,OCT,1998)

public method test_39():
    assume next(Date(21,NOV,1998)) == Date(22,NOV,1998)

public method test_40():
    assume next(Date(2,JAN,1999)) == Date(3,JAN,1999)

public method test_41():
    assume next(Date(16,FEB,1999)) == Date(17,FEB,1999)

public method test_42():
    assume next(Date(24,FEB,1999)) == Date(25,FEB,1999)

public method test_43():
    assume next(Date(3,APR,1999)) == Date(4,APR,1999)

public method test_44():
    assume next(Date(20,MAY,1999)) == Date(21,MAY,1999)

public method test_45():
    assume next(Date(28,JUN,1999)) == Date(29,JUN,1999)

public method test_46():
    assume next(Date(11,AUG,1999)) == Date(12,AUG,1999)

public method test_47():
    assume next(Date(18,SEP,1999)) == Date(19,SEP,1999)

public method test_48():
    assume next(Date(19,SEP,1999)) == Date(20,SEP,1999)

public method test_49():
    assume next(Date(28,OCT,1999)) == Date(29,OCT,1999)

public method test_50():
    assume next(Date(5,DEC,1999)) == Date(6,DEC,1999)

public method test_51():
    assume next(Date(9,JAN,2000)) == Date(10,JAN,2000)

public method test_52():
    assume next(Date(31,JAN,2000)) == Date(1,FEB,2000)

public method test_53():
    assume next(Date(17,MAR,2000)) == Date(18,MAR,2000)

public method test_54():
    assume next(Date(25,MAR,2000)) == Date(26,MAR,2000)

public method test_55():
    assume next(Date(4,MAY,2000)) == Date(5,MAY,2000)

public method test_56():
    assume next(Date(18,MAY,2000)) == Date(19,MAY,2000)

public method test_57():
    assume next(Date(13,JUN,2000)) == Date(14,JUN,2000)

public method test_58():
    assume next(Date(17,JUL,2000)) == Date(18,JUL,2000)

public method test_59():
    assume next(Date(16,AUG,2000)) == Date(17,AUG,2000)

public method test_60():
    assume next(Date(6,SEP,2000)) == Date(7,SEP,2000)

public method test_61():
    assume next(Date(17,OCT,2000)) == Date(18,OCT,2000)

public method test_62():
    assume next(Date(9,NOV,2000)) == Date(10,NOV,2000)

public method test_63():
    assume next(Date(30,NOV,2000)) == Date(1,DEC,2000)

public method test_64():
    assume next(Date(17,DEC,2000)) == Date(18,DEC,2000)

public method test_65():
    assume next(Date(7,JAN,2001)) == Date(8,JAN,2001)

public method test_66():
    assume next(Date(19,FEB,2001)) == Date(20,FEB,2001)

public method test_67():
    assume next(Date(25,FEB,2001)) == Date(26,FEB,2001)

public method test_68():
    assume next(Date(8,MAR,2001)) == Date(9,MAR,2001)

public method test_69():
    assume next(Date(26,MAR,2001)) == Date(27,MAR,2001)

public method test_70():
    assume next(Date(6,APR,2001)) == Date(7,APR,2001)

public method test_71():
    assume next(Date(28,APR,2001)) == Date(29,APR,2001)

public method test_72():
    assume next(Date(18,MAY,2001)) == Date(19,MAY,2001)

public method test_73():
    assume next(Date(15,JUN,2001)) == Date(16,JUN,2001)

public method test_74():
    assume next(Date(4,JUL,2001)) == Date(5,JUL,2001)

public method test_75():
    assume next(Date(31,JUL,2001)) == Date(1,AUG,2001)

public method test_76():
    assume next(Date(16,AUG,2001)) == Date(17,AUG,2001)

public method test_77():
    assume next(Date(27,AUG,2001)) == Date(28,AUG,2001)

public method test_78():
    assume next(Date(30,AUG,2001)) == Date(31,AUG,2001)

public method test_79():
    assume next(Date(8,OCT,2001)) == Date(9,OCT,2001)

public method test_80():
    assume next(Date(31,OCT,2001)) == Date(1,NOV,2001)

public method test_81():
    assume next(Date(3,DEC,2001)) == Date(4,DEC,2001)

public method test_82():
    assume next(Date(8,DEC,2001)) == Date(9,DEC,2001)

public method test_83():
    assume next(Date(16,JAN,2002)) == Date(17,JAN,2002)

public method test_84():
    assume next(Date(17,JAN,2002)) == Date(18,JAN,2002)

public method test_85():
    assume next(Date(17,JAN,2002)) == Date(18,JAN,2002)

public method test_86():
    assume next(Date(2,MAR,2002)) == Date(3,MAR,2002)

public method test_87():
    assume next(Date(17,MAR,2002)) == Date(18,MAR,2002)

public method test_88():
    assume next(Date(27,MAR,2002)) == Date(28,MAR,2002)

public method test_89():
    assume next(Date(16,APR,2002)) == Date(17,APR,2002)

public method test_90():
    assume next(Date(22,APR,2002)) == Date(23,APR,2002)

public method test_91():
    assume next(Date(4,JUN,2002)) == Date(5,JUN,2002)

public method test_92():
    assume next(Date(3,JUL,2002)) == Date(4,JUL,2002)

public method test_93():
    assume next(Date(14,JUL,2002)) == Date(15,JUL,2002)

public method test_94():
    assume next(Date(21,JUL,2002)) == Date(22,JUL,2002)

public method test_95():
    assume next(Date(30,JUL,2002)) == Date(31,JUL,2002)

public method test_96():
    assume next(Date(19,AUG,2002)) == Date(20,AUG,2002)

public method test_97():
    assume next(Date(27,SEP,2002)) == Date(28,SEP,2002)

public method test_98():
    assume next(Date(15,NOV,2002)) == Date(16,NOV,2002)

public method test_99():
    assume next(Date(15,DEC,2002)) == Date(16,DEC,2002)

public method test_100():
    assume next(Date(7,JAN,2003)) == Date(8,JAN,2003)
