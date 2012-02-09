import Point
import Ray

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
    rOrigin = Point.subtract(r.origin, s.origin)
    
    A = Vector.dot(r.direction, r.direction)
    B = 2 * Vector.dot(r.direction, rOrigin)
    C = Vector.dot(rOrigin,rOrigin) - (s.radius * s.radius)

    t = solveQuadratic(A,B,C,0.0001)    

    if t == null:
        // there is no intersection!
        return null
    t0,t1 = t

    return project(r,t0),project(r,t1)

// Find solutions for x in a quadratric equation of the form:
//
//  Ax^2 + Bx + C = 0.  
//
// This is of course a classic problem and there are not 
// necessarily any real solutions.  This method will only return
// return solutions, or null if there are none.
null|(real,real) solveQuadratic(real A, real B, real C, real err):
    discriminant = (B*B) - 4*A*C
    if discriminant < 0:
        // no real roots
        return null

    // HACK
    discriminant = Math.round(discriminant * 100) / 100.0    

    root = Math.sqrt(discriminant,err)
    
    _2A = 2*A
    t0 = (-B - root) / _2A
    t1 = (-B + root) / _2A
    return (t0,t1)
       
// project a given ray by a certain amount of distance
public Point project(Ray ray, real dist):
    d = ray.direction
    o = ray.origin
    x = (d.x * dist) + o.x
    y = (d.y * dist) + o.y
    z = (d.z * dist) + o.z
    return Point(x,y,z)
