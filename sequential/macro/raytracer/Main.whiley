import * from whiley.lang.System

void ::main(System.Console sys):
    v1 = (1,5,0)
    v2 = (4,-2,-1)
    sys.out.println("||V1|| = " + Real.toDecimal(Vector.length(v1),5))
    sys.out.println("||V2|| = " + Real.toDecimal(Vector.length(v2),5))
    sys.out.println("V1 * V2 = " + Vector.dot(v1,v2))

