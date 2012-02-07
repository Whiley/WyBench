import * from Point
import * from Ray

// A Sphere is the simplest object to ray trace.  If we have a sphere
// of radius r centered at position c, then any point p on the sphere
// must satisfy |p-c|^2 - r^2 = 0
define Sphere as {
    Point origin,
    real radius
}

public Sphere Sphere(Point origin, real radius):
    return { 
        origin: origin,
        radius: radius 
    }

// Determine whether the given vector intersects the 
// given box.  When there is an intersection there will 
// be an entry and exit point.  This function returns 
// these or null if there is no intersection.
public null|(Point,Point) intersect(Sphere s, Ray r):
    // transform into object space
    rOrigin = Point.subtract(s.origin, r.origin)
    
    A = Vector.dot(r.direction, r.direction)
    B = 2 * Vector.dot(r.direction, rOrigin)
    C = Vector.dot(rOrigin,rOrigin) - (s.radius * s.radius)
    
    t0,t1 = solveQuadratic(A,B,C)    
    
    // TODO: somewhere here I need to decide whether or not there is
    // actually an intersection.
    
    return Ray.project(r,t0),Ray.project(r,t1)

(real,real) solveQuadratic(real A, real B, real C):
    rB2m4AC = Math.sqrt((B*B) - 4*A*C,0.0001)
    t0 = (-B - rB2m4AC) / (2*A)
    t1 = (-B + rB2m4AC) / (2*A)
    return (t0,t1)
    
    
