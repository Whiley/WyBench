import * from Point
import * from Vector

// A ray is described by an origin point, and a 
// directional (unit) vector.
define Ray as { Point origin, Vector direction }

public Ray Ray(Point origin, Vector direction):
    return { origin: origin, direction: direction }

// project a given ray by a certain amount of distance
public Point project(Ray ray, real dist):
    d = ray.direction
    o = ray.origin
    x = (d.x * dist) + o.x
    y = (d.y * dist) + o.y
    z = (d.y * dist) + o.z
    return Point(x,y,z)
