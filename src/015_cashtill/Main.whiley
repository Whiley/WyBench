import whiley.lang.*

type nat is (int n) where n >= 0

/**
 * Define coins/notes and their values (in cents)
 */
constant ONE_CENT is 0
constant FIVE_CENTS is 1
constant TEN_CENTS is 2
constant TWENTY_CENTS is 3
constant FIFTY_CENTS is 4
constant ONE_DOLLAR is 5  // 1 dollar
constant FIVE_DOLLARS is 6  // 5 dollars
constant TEN_DOLLARS is 7 // 10 dollars

constant Value is [
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
type Cash is (nat[] ns) where |ns| == |Value|

function Cash() -> Cash:
    return [0,0,0,0,0,0,0,0]

function Cash(nat[] coins) -> Cash
// No coin in coins larger than permitted values
requires all { i in 0..|coins| | coins[i] < |Value| }:
    Cash cash = [0,0,0,0,0,0,0,0]
    int i = 0
    while i < |coins| 
        where |cash| == |Value| && all {k in 0..|cash| | cash[k] >= 0}:
        nat coin = coins[i]
        cash[coin] = cash[coin] + 1
        i = i + 1
    return cash

/**
 * Given some cash, compute its total
 */ 
function total(Cash c) -> int:
    int r = 0
    int i = 0
    while i < |c|:
        r = r + (Value[i] * c[i])
        i = i + 1
    return r

/**
 * Checks that a second load of cash is stored entirely within the first.
 * In other words, if we remove the second from the first then we do not
 * get any negative amounts.
 */
function contained(Cash first, Cash second) -> bool:
    int i = 0
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
    int i = 0
    while i < |first|:
        first[i] = first[i] + second[i]
        i = i + 1
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
    int i = 0
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
function calculateChange(Cash till, nat change) -> (null|Cash r)
// If change is given, then it must have been in the till, and must
// equal that requested.
ensures r is Cash ==> (contained(till,r) && total(r) == change):
    //
    if change == 0:
        return Cash()
    else:
        // exhaustive search through all possible coins
        nat i = 0
        while i < |till|:
            if till[i] > 0 && Value[i] <= change:
                Cash tmp = till
                // temporarily take coin out of till
                tmp[i] = tmp[i] - 1 
                null|Cash chg = calculateChange(tmp,change - Value[i])
                if chg != null:
                    // we have enough change
                    chg[i] = chg[i] + 1
                    return chg
            i = i + 1
        // cannot give exact change :( 
        return null
/**
 * Print out cash in a friendly format
 */
function toString(Cash c) -> ASCII.string:
    ASCII.string r = ""
    bool firstTime = true
    int i = 0
    while i < |c|:
        int amt = c[i]
        if amt != 0:
            if !firstTime:
                r = Array.append(r,", ")
            firstTime = false
            r = Array.append(r,Int.toString(amt))
            r = Array.append(r," x ")
            r = Array.append(r,Descriptions[i])
        i = i + 1
    if r == "":
        r = "(nothing)"
    return r
    
constant Descriptions is [
    "1c",
    "5c",
    "10c",
    "20c",
    "50c",
    "$1",
    "$5",
    "$10"
]

/**
 * Run through the sequence of a customer attempting to purchase an item
 * of a specified cost using a given amount of cash and a current till.
 */
public method buy(System.Console console, Cash till, Cash given, int cost) -> Cash:
    console.out.println_s("--")
    console.out.print_s("Customer wants to purchase item for ")
    console.out.print_s(Int.toString(cost))
    console.out.println_s("c.")
    console.out.print_s("Customer gives: ")
    console.out.println_s(toString(given))
    if total(given) < cost:
        console.out.println_s("Customer has not given enough cash!")
    else:
        Cash|null change = calculateChange(till,total(given) - cost)
        if change == null:
            console.out.println_s("Cash till cannot give exact change!")
        else:
            console.out.print_s("Change given: ")
            console.out.println_s(toString(change))
            till = add(till,given)
            till = subtract(till,change)
            console.out.print_s("Till: ")
            console.out.println_s(toString(till))
    return till

/**
 * Test Harness
 */
public method main(System.Console console):
    Cash till = [5,3,3,1,1,3,0,0]
    console.out.print_s("Till: ")
    console.out.println_s(toString(till))
    // now, run through some sequences...
    till = buy(console,till,Cash([ONE_DOLLAR]),85)
    till = buy(console,till,Cash([ONE_DOLLAR]),105)
    till = buy(console,till,Cash([TEN_DOLLARS]),5)
    till = buy(console,till,Cash([FIVE_DOLLARS]),305)

