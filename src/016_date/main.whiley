import std::array
import std::ascii
import std::io

int JAN = 1
int FEB = 2
int MAR = 3
int APR = 4
int MAY = 5
int JUN = 6
int JUL = 7
int AUG = 8
int SEP = 9
int OCT = 10
int NOV = 11
int DEC = 12

type day is (int d) where 1 <= d && d <= 31
type month is (int x) where JAN <= x && x <= DEC

// =================================================
// Date
// =================================================

type Date is ({
    day day,
    month month,
    int year
} d) where (d.day <= 30 || (d.month != SEP && d.month != APR && d.month != JUN && d.month != NOV)) &&
        (d.month != FEB || d.day <= 29 ) // && // normal restriction
        // FIXME: put back support for leap years
        // (d.month != FEB || d.year % 4 != 0 || (d.year % 100 == 0 && d.year % 400 != 0) || d.day <= 28) // leap-year restriction

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
        if date.month == DEC:
            date.year = date.year + 1
            date.month = JAN
        else:
            date.month = date.month + 1
    else:
        date.day = date.day + 1
    // done
    return date

function to_string(Date date) -> ascii::string:
    ascii::string d = ascii::to_string(date.day)
    ascii::string m = ascii::to_string(date.month)
    ascii::string y = ascii::to_string(date.year)
    ascii::string r = array::append(d,"/")
    r = array::append(r,m)
    r = array::append(r,"/")
    return array::append(r,y)

// =================================================
// Test Harness
// =================================================

method main(ascii::string[] args):
    Date start = Date(1,JAN,2000)
    Date end = Date(6,JAN,2013)
    while start != end:
        io::println(to_string(start))    
        start = next(start)
