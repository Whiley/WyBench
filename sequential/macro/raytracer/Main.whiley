import * from whiley.lang.System

void ::main(System.Console sys):
    p1 = Point.Point(1,2,-2)
    p2 = Point.Point(3,-2,1)
    p3 = Point.Point(5,1,-4)
    plane = Plane.Plane(p1,p2,p3)
    sys.out.println("A = " + Real.toDecimal(plane.A,5) + 
                    ", B = " + Real.toDecimal(plane.B,5) + 
                    ", C = " + Real.toDecimal(plane.C,5) + 
                    ", D = " + Real.toDecimal(plane.D,5))
