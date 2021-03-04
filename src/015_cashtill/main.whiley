import std::array
import std::ascii
import uint from std::integer

/**
 * Define coins/notes and their values (in cents)
 */
uint ONE_CENT = 0
uint FIVE_CENTS = 1
uint TEN_CENTS = 2
uint TWENTY_CENTS = 3
uint FIFTY_CENTS = 4
uint ONE_DOLLAR = 5  // 1 dollar
uint FIVE_DOLLARS = 6  // 5 dollars
uint TEN_DOLLARS = 7 // 10 dollars

uint[] Value = [
    1,
    5,
    10,
    20,
    50,
    100,
    500,
    1000
]

/**
 * Define the notion of cash as an array of coins / notes
 */
type Cash is (uint[] ns) where |ns| == |Value|

function Cash() -> Cash:
    return [0,0,0,0,0,0,0,0]

function Cash(uint[] coins) -> Cash
// No coin in coins larger than permitted values
requires all { i in 0..|coins| | coins[i] < |Value| }:
    Cash cash = [0,0,0,0,0,0,0,0]
    uint i = 0
    while i < |coins| 
        where |cash| == |Value| && all {k in 0..|cash| | cash[k] >= 0}:
        uint coin = coins[i]
        cash[coin] = cash[coin] + 1
        i = i + 1
    return cash

/**
 * Given some cash, compute its total
 */ 
function total(Cash c) -> int:
    int r = 0
    for i in 0..|c|:
        r = r + (Value[i] * c[i])
    //
    return r

/**
 * Checks that a second load of cash is stored entirely within the first.
 * In other words, if we remove the second from the first then we do not
 * get any negative amounts.
 */
function contained(Cash first, Cash second) -> bool:
    uint i = 0
    while i < |first|:
        if first[i] < second[i]:
            return false
        i = i + 1
    return true

/**
 * Adds two bits of cash together
 *
 * ENSURES: the total returned equals total of first plus
 *          the total of the second.
 */
function add(Cash first, Cash second) -> (Cash r)
// Result total must be sum of argument totals
ensures total(r) == total(first) + total(second):
    //
    for i in 0..|first|:
        first[i] = first[i] + second[i]
    //
    return first

/**
 * Subtracts from first bit of cash a second bit of cash.
 *
 * REQUIRES: second cash is contained in first.
 *
 * ENSURES: the total returned equals total of first less
 *          the total of the second.
 */
function subtract(Cash first, Cash second) -> (Cash r)
// First argument must contain second; for example, if we have 1
// dollar coin and a 1 cent coin, we cannot subtract a 5 dollar note!
requires contained(first,second)
// Total returned must total of first argument less second
ensures total(r) == total(first) - total(second):
    //
    uint i = 0
    while i < |first|:
        first[i] = first[i] - second[i]
        i = i + 1
    //
    return first

/**
 * Determine the change to be returned to a customer from a given cash
 * till, assuming a certain cost for the item and the cash that was
 * actually given.  Observe that the specification for this method does 
 * not dictate how the change is to be computed --- only that it must 
 * have certain properties.  Finally, if exact change cannot be given 
 * from the till then null is returned.
 *
 * ENSURES:  if change returned, then it must be contained in till, and 
 *           the amount returned must equal the amount requested.
 */
function calculateChange(Cash till, uint change) -> (null|Cash r)
// If change is given, then it must have been in the till, and must
// equal that requested.
ensures r is Cash ==> (contained(till,r) && total(r) == change):
    //
    if change == 0:
        return Cash()
    else:
        // exhaustive search through all possible coins
        uint i = 0
        while i < |till|:
            if till[i] > 0 && Value[i] <= change:
                Cash tmp = till
                // temporarily take coin out of till
                tmp[i] = tmp[i] - 1 
                null|Cash chg = calculateChange(tmp,change - Value[i])
                if chg is Cash:
                    // we have enough change
                    chg[i] = chg[i] + 1
                    return chg
            i = i + 1
        // cannot give exact change :( 
        return null

// ====================================================
// Tests
// ====================================================

public method test_01():
    // Cash available in till
    Cash till = [5,3,3,1,1,3,0,0]
    // Determine change
    assume calculateChange(till,25) == [5,1,1,0,0,0,0]
