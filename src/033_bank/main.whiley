import uint from std::integer
import u16 from std::integer

type Account is { u16 address, u16 balance }
//
type State is {
    u16 owner,         // creator of the bank
    u16[] balances    // list of account balances
} where |balances| == 65536

// ========================================================================
// Constructor
// ========================================================================

function TinyBank(u16 sender) -> (State r)
// Initial state is all empty
ensures r.owner == sender:
    //
    return { owner: sender, balances: [0; 65536] }

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
// Transfer
// ========================================================================

function transfer(State state, u16 sender, u16 recipient, u16 amount) -> (State r)
// Sender must have sufficient funds and is not recipient
requires state.balances[sender] >= amount && sender != recipient
// Recipient must have sufficient space
requires (state.balances[recipient] + amount) < 65536
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
    
    