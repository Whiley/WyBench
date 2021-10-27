import uint from std::integer
import u16 from std::integer

final int MAX_ACCOUNTS = 256

//
type State is {
    u16 owner,         // creator of the bank
    u16[] balances    // list of account balances
} where |balances| == MAX_ACCOUNTS

// ========================================================================
// Constructor
// ========================================================================

function TinyBank(u16 sender) -> (State r)
// Initial state is all empty
ensures r.owner == sender
// Created all possible accounts
ensures |r.balances| == MAX_ACCOUNTS
// Everyones balance is zero
ensures all { k in 0..|r.balances| | r.balances[k] == 0 }:
    //
    return { owner: sender, balances: [0; MAX_ACCOUNTS] }

// ========================================================================
// Minting Cash
// ========================================================================

function mint(State state, u16 sender, u16 address, u16 amount) -> (State r)
// Only owner can mint new coins
requires state.owner == sender
// Balance for account beforehand must be empty
requires state.balances[address] == 0
// Balance for account aftewards has given amount
ensures r.balances[address] == amount
// All other accounts remain unchanged
ensures unchangedExcept(state.balances,address,r.balances):
    //
    state.balances[address] = amount
    //
    return state

// ========================================================================
// Check Balance
// ========================================================================

function balance(State state, u16 sender) -> (u16 r)
// Valid account required
requires sender < |state.balances|
// Balance returned is correct
ensures state.balances[sender] == r:
    //
    return state.balances[sender]

// ========================================================================
// Transfer
// ========================================================================

function transfer(State state, u16 sender, u16 recipient, u16 amount) -> (State r)
// Sender must have sufficient funds and is not recipient
requires state.balances[sender] >= amount && sender != recipient
// Recipient must have sufficient space
requires (state.balances[recipient] + amount) < MAX_ACCOUNTS
// Everyone else unchanged:
ensures unchangedExcept(state.balances,sender,recipient,r.balances)
// Money removed from sender
ensures r.balances[sender] == state.balances[sender] - amount
// Money given to recipient
ensures r.balances[recipient] == state.balances[recipient] + amount:
    //
    state.balances[sender] = state.balances[sender] - amount
    state.balances[recipient] = state.balances[recipient] + amount
    //
    return state

// ========================================================================
// Helpers
// ========================================================================

property unchangedExcept(int[] before, int ith, int[] after)
where unchangedExcept(before,ith,ith,after)

property unchangedExcept(int[] before, int ith, int jth, int[] after)
// Size before must be unchanged
where |before| == |after|
// All items unchanged between before and after except ith
where all { i in 0..|before| | i == ith || i == jth || before[i] == after[i] }

// ========================================================================
// Tests
// ========================================================================

public final u16 OWNER = 1234
public final u16 JOHN = 0
public final u16 JANE = 1
public final u16 OTHER = 2

public method test_01():
    // Create empty bank
    State b = TinyBank(OWNER)    
    // No one has any cash!
    assert balance(b,JOHN) == 0
    assert balance(b,JANE) == 0

public method test_02():
    // Create empty bank
    State b = TinyBank(OWNER)
    // Mint some cash
    b = mint(b,OWNER,JOHN,200)
    // Balance matches!
    assert balance(b,JOHN) == 200
    // No one else has any cash!
    assert balance(b,JANE) == 0

public method test_03():
    // Create empty bank
    State b = TinyBank(OWNER)
    // Mint some cash
    b = mint(b,OWNER,JOHN,500)
    // Transfer some
    b = transfer(b,JOHN,JANE,200)
    // Balance decreased!
    assert balance(b,JOHN) == 300
    // Jane has some cash!
    assert balance(b,JANE) == 200
    // No one else has any cash still
    assert balance(b,OTHER) == 0