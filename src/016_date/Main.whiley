import whiley.lang.*
import string from whiley.lang.ASCII

constant JAN is 1
constant FEB is 2
constant MAR is 3
constant APR is 4
constant MAY is 5
constant JUN is 6
constant JUL is 7
constant AUG is 8
constant SEP is 9
constant OCT is 10
constant NOV is 11
constant DEC is 12

type day is (int d) where d <= 1 && d <= 31

type month is (int x) where JAN <= x && x <= DEC

// =================================================
// Date
// =================================================

type Date is {
    day day,
    month month,
    int year
} where (day <= 30 || (month != SEP && month != APR && month != JUN && month != NOV)) &&
        (month != FEB || day <= 29 ) && // normal restriction
        (month != FEB || year % 4 != 0 || (year % 100 == 0 && year % 400 != 0) || day <= 28) // leap-year restriction

function Date(day day, month month, int year) -> Date
// 30 days hath September, April, June and November.
requires day <= 30 || (month != SEP && month != APR && month != JUN && month != NOV)
requires month != FEB || day <= 29
requires month != FEB || year % 4 != 0 || (year % 100 == 0 && year % 400 != 0) || day <= 28:
    //
    return {
        day: day,
        month: month,
        year: year
    }

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
        date.month = date.month + 1
        if date.month == 13:
            date.year = date.year + 1
            date.month = JAN
    else:
        date.day = date.day + 1
    // done
    return date

function toString(Date date) -> string:
    string d = Int.toString(date.day)
    string m = Int.toString(date.month)
    string y = Int.toString(date.year)
    string r = Array.append(d,"/")
    r = Array.append(r,m)
    r = Array.append(r,"/")
    return Array.append(r,y)

// =================================================
// Test Harness
// =================================================

method main(System.Console console):
    Date start = Date(1,JAN,2000)
    Date end = Date(6,JAN,2013)
    while start != end:
        console.out.println_s(toString(start))    
        start = next(start)
