define Pos as (int,int)

int abs(int x):
    if x < 0:
        return -x
    else:
        return x

bool conflict(Pos p, int row, int col):
    r,c = p
    if r == row || c == col:
        return true
    colDiff = abs(c - col)
    rowDiff = abs(r - row)
    return colDiff == rowDiff
    

[[Pos]] run([Pos] queens, int n, int dim):
    if dim == n:
        return [queens]
    else:
        solutions = []
        for col in 0..dim:
            solution = true
            for i in 0..n:
                p = queens[i]
                if conflict(p,n,col):
                    solution = false
                    break
            if solution:
                queens[n] = (n,col)
                solutions = solutions + run(queens,n+1,dim)                    
        return solutions

void System::main([string] args):
    dim = 10
    init = []
    for i in 0..dim:
        init = init + (0,0)
    solutions = run(init,0,dim)
    out.println("Found " + str(|solutions|) + " solutions.")
