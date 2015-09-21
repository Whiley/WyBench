import whiley.lang.System

constant RED is 0
constant WHITE is 1
constant BLUE is 2

type Color is (int n) 
// The dutch national flag has three colours
where n == RED || n == WHITE || n == BLUE 

function partition(Color[] cols) -> (Color[] r):
    int i = 0
    int j = 0
    int n = |cols|-1

    while j <= n:
        if cols[j] < WHITE:
            cols = swap(cols,i,j)
            i = i + 1
            j = j + 1
        else if cols[j] > WHITE:
            cols = swap(cols,j,n)
            n = n - 1
        else:
            j = j + 1
    //
    return cols

function swap(Color[] cols, int i, int j) -> (Color[] r):
    int tmp = cols[i]
    cols[i] = cols[j]
    cols[j] = tmp
    return cols

public method main(System.Console console):
    int[] colors = [WHITE,RED,BLUE,WHITE]
    //
    colors = partition(colors)
    //
    console.out.println(colors)