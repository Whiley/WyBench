import * from Point

// The plane is represented using the classical "plane equation" 
// where for any point x,y,z on the plane we have Ax+By+Cz+D=0.  
// Furthermore, the cooefficients are ensured to be normalised, 
// such that sqrt(A^2+B^2+C^2) = 1

define Plane as {
    real A,
    real B,
    real C,
    real D
}

// Construct a plane from three distinct points which lie on the
// plane.
public Plane Plane(Point p1, Point p2, Point p3) requires p1 != p2 && p1 != p3 && p2 != p3:
    // first, compute the coefficients
    A = p1.y*(p2.z-p3.z) + p2.y*(p3.z-p1.z) + p3.y*(p1.z-p2.z)
    B = p1.z*(p2.x-p3.x) + p2.z*(p3.x-p1.x) + p3.z*(p1.x-p2.x)
    C = p1.x*(p2.y-p3.y) + p2.x*(p3.y-p1.y) + p3.x*(p1.y-p2.y)
    D = p1.x*((p2.y * p3.z) - (p3.y*p2.z)) + 
        p2.x*((p3.y * p1.z) - (p1.y*p3.z)) +
        p3.x*((p1.y * p2.z) - (p2.y*p1.z))
    // second, normalise them
    len = Math.sqrt(A*A + B*B + C*C,0.0001)
    return {A:A/len, B:B/len, C:C/len, D:-D}


// Determine the distance of a point from the plane.
public real distance(Plane plane, Point p):
    return (p.x * plane.A) + (p.y * plane.B) + 
        (p.z * plane.C) + plane.D

// Determine the intersection point of a vecctor and plane.  In the
// case that no intersection exists (i.e. they are parallel to each
// other) then null is returned.
public null|Point intersection(Plane plane, Vector v):
    

