define Vector as (real,real,real)

define ERROR as 0.001

public real length(Vector a):
    a1,a2,a3 = a
    sum = (a1*a1) + (a2*a2) + (a3*a3)
    return Math.sqrt(sum,ERROR)

public Vector cross(Vector a, Vector b):
    a1,a2,a3 = a
    b1,b2,b3 = b
    c1 = (a2*b3) - (a3*b2)
    c2 = (a3*b1) - (a1*b3)
    c3 = (a1*b2) - (a2*b1)
    return c1,c2,c3
    

public real dot(Vector a, Vector b):
    a1,a2,a3 = a
    b1,b2,b3 = b
    return (a1*b1) + (a2*b2) + (a3*b3)

// Return a normalised vector pointing in the same direction as the
// parameter.
public Vector normalise(Vector a):
    a1,a2,a3 = a
    len = length(a)
    return a1/len,a2/len,a3/len



