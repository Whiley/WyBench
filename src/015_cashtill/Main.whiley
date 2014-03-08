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
type Cash is ([nat] ns) where |ns| == |Value|

function Cash() => Cash:
    return [0,0,0,0,0,0,0,0]

function Cash([nat] coins) => Cash
// No coin in coins larger than permitted values
requires no { c in coins | c >= |Value| }:
    Cash cash = [0,0,0,0,0,0,0,0]
    for i in coins where |cash| == |Value| && no {c in cash | c < 0}:
        cash[i] = cash[i] + 1
    return cash

/**
 * Given some cash, compute its total
 */ 
function total(Cash c) => int:
    int r = 0
    for i in 0..|c|:
        r = r + (Value[i] * c[i])
    return r

/**
 * Checks that a second load of cash is stored entirely within the first.
 * In other words, if we remove the second from the first then we do not
 * get any negative amounts.
 */
function contained(Cash first, Cash second) => bool:
    for i in 0..|first|:
        if first[i] < second[i]:
            return false
    return true

/**
 * Adds two bits of cash together
 *
 * ENSURES: the total returned equals total of first plus
 *          the total of the second.
 */
function add(Cash first, Cash second) => (Cash r)
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
function subtract(Cash first, Cash second) => (Cash r)
// First argument must contain second; for example, if we have 1
// dollar coin and a 1 cent coin, we cannot subtract a 5 dollar note!
requires contained(first,second)
// Total returned must total of first argument less second
ensures total(r) == total(first) - total(second):
    //
    for i in 0..|first|:
        first[i] = first[i] - second[i]
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
function calculateChange(Cash till, nat change) => (null|Cash r)
// If change is given, then it must have been in the till, and must
// equal that requested.
ensures r != null ==> (contained(till,r) && total(r) == change):
    //
    if change == 0:
        return Cash()
    else:
        // exhaustive search through all possible coins
        for coin in 0 .. |till|:
            if till[coin] > 0 && Value[coin] <= change:
                null|Cash tmp = till
                // temporarily take coin out of till
                tmp[coin] = tmp[coin] - 1 
                tmp = calculateChange(tmp,change - Value[coin])
                if tmp != null:
                    // we have enough change
                    tmp[coin] = tmp[coin] + 1
                    return tmp 
        // cannot give exact change :( 
        return null
/**
 * Print out cash in a friendly format
 */
function toString(Cash c) => string:
    string r = ""
    bool firstTime = true
    for i in 0..|c|:
        int amt = c[i]
        if amt != 0:
            if !firstTime:
                r = r ++ ", "
            firstTime = false
            r = r ++ amt ++ " x " ++ Descriptions[i]
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
public method buy(System.Console console, Cash till, Cash given, int cost) => Cash:
    console.out.println("--")
    console.out.println("Customer wants to purchase item for " ++ cost ++ "c.")
    console.out.println("Customer gives: " ++ toString(given))
    if total(given) < cost:
        console.out.println("Customer has not given enough cash!")
    else:
        Cash|null change = calculateChange(till,total(given) - cost)
        if change == null:
            console.out.println("Cash till cannot given exact change!")
        else:
            console.out.println("Change given: " ++ toString(change))
            till = add(till,given)
            till = subtract(till,change)
            console.out.println("Till: " ++ toString(till))
    return till

/**
 * Test Harness
 */
public method main(System.Console console):
    Cash till = [5,3,3,1,1,3,0,0]
    console.out.println("Till: " ++ toString(till))
    // now, run through some sequences...
    till = buy(console,till,Cash([ONE_DOLLAR]),85)
    till = buy(console,till,Cash([ONE_DOLLAR]),105)
    till = buy(console,till,Cash([TEN_DOLLARS]),5)
    till = buy(console,till,Cash([FIVE_DOLLARS]),305)

