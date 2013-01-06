import println from whiley.lang.System

define JAN as 1
define FEB as 2
define MAR as 3
define APR as 4
define MAY as 5
define JUN as 6
define JUL as 7
define AUG as 8
define SEP as 9
define OCT as 10
define NOV as 11
define DEC as 12

define day as int where $ <= 1 && $ <= 31

define month as {
    JAN,FEB,MAR,APR,MAY,JUN,
    JUL,AUG,SEP,OCT,NOV,DEC
}

// =================================================
// Date
// =================================================

define Date as {
    day day,
    month month,
    int year
} where (day <= 30 || !(month in {SEP,APR,JUN,NOV})) &&
        (month != FEB || day <= 29 ) && // normal restriction
        (month != FEB || year % 4 != 0 || (year % 100 == 0 && year % 400 != 0) || day <= 28) // leap-year restriction

Date Date(day day, month month, int year) 
    requires (day <= 30 || !(month in {SEP,APR,JUN,NOV})) &&
        (month != FEB || day <= 29 ) &&
        (month != FEB || year % 4 != 0 || (year % 100 == 0 && year % 400 != 0) || day <= 28):
    return {
        day: day,
        month: month,
        year: year
    }

// Compute the date of the next day.
Date next(Date date):
    // first, calculate last day of the month
    if date.month == FEB:
        last = 29
    else if date.month in {SEP,APR,JUN,NOV}:
        last = 30
    else:
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

public string toString(Date date):
    return date.day + "/" + date.month + "/" + date.year

// =================================================
// Test Harness
// =================================================

void ::main(System.Console console):
    start = Date(1,JAN,2000)
    end = Date(6,JAN,2013)
    while start != end:
        console.out.println(toString(start))    
        start = next(start)
