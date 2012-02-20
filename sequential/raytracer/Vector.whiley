public define Vector as {
    real x,
    real y,
    real z
}

define ERROR as 0.001

public Vector Vector(real x, real y, real z):
    return { x:x, y:y, z:z }

public real length(Vector a):
    sum = (a.x*a.x) + (a.y*a.y) + (a.z*a.z)

    // HACK    
    sum = Math.round(sum * 100) / 100.0        

    return Math.sqrt(sum,ERROR)

public Vector cross(Vector a, Vector b):
    x = (a.y*b.z) - (a.z*b.y)
    y = (a.z*b.x) - (a.x*b.z)
    z = (a.x*b.y) - (a.y*b.x)
    return { x:x, y:y, z:z }
   
public real dot(Vector a, Vector b):
    return (a.x*b.x) + (a.y*b.y) + (a.z*b.z)

// Return a unit vector pointing in the same direction as the
// original.
public Vector Unit(Vector a):
    len = length(a)
    return { 
        x: a.x / len,
        y: a.y / len,
        z: a.z / len
    }



