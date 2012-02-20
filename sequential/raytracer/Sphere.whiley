import Point
import Ray

// A Sphere is the simplest object to ray trace.  If we have a sphere
// of radius r centered at position c, then any point p on the sphere
// must satisfy |p-c|^2 - r^2 = 0
define Sphere as {
    Point origin,
    real radius,
    real radius2
}

public Sphere Sphere(Point origin, real radius):
    return { 
        origin: origin,
        radius: radius,
        radius2: radius * radius // useful
    }

// Determine whether the given vector intersects the 
// given box.  When there is an intersection there will 
// be an entry and exit point.  This function returns 
// these or null if there is no intersection.
public null|(Point,Point) intersect(Sphere s, Ray r):
    // transform into object space
    rOrigin = Point.subtract(r.origin, s.origin)
    
    // Find solutions for x in a quadratric equation of the form:
    //
    //  Ax^2 + Bx + C = 0.  
    //    
    // This is of course a classic problem and there are not 
    // necessarily any real solutions.  This method will only return
    // return solutions, or null if there are none.
    //
    // yes, it's ugly.  That's because I'm carefully trying to reduce
    // the number of arithmetic operations involved.

    rdir = r.direction
    rdir_x = rdir.x    
    rdir_y = rdir.y    
    rdir_z = rdir.z
    rorg_x = rOrigin.x
    rorg_y = rOrigin.y
    rorg_z = rOrigin.z
    
    A = rdir_x*rdir_x + rdir_y*rdir_y + rdir_z*rdir_z    
    B = rorg_x*rdir_x + rorg_y*rdir_y + rorg_z*rdir_z
    C = rorg_x*rorg_x + rorg_y*rorg_y + rorg_z*rorg_z
    C = C - s.radius2

    discriminant = (B*B) - A*C
    
    if discriminant < 0:
        // no real roots (implies no solutions)
        return null

    // HACK
    discriminant = Math.round(discriminant * 100) / 100.0    
    root = Math.sqrt(discriminant,0.001)
        
    _2A = 2*A
    t0 = (-B - root) // _2A
    t1 = (-B + root) // _2A
    
    return project(r,t0),project(r,t1)
   
// project a given ray by a certain amount of distance
public Point project(Ray ray, real dist):
    d = ray.direction
    o = ray.origin
    x = (d.x * dist) + o.x
    y = (d.y * dist) + o.y
    z = (d.z * dist) + o.z
    return Point(x,y,z)
