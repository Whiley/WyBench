int fib(int x):
    if x <= 1:
        return 1
    else:
        return fib(x-1) + fib(x-2)

void System::main([string] args):
    for i in 1 .. 41:
        r = fib(i)
        out.println(str(r))