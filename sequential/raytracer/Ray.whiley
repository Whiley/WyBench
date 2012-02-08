import * from Point
import * from Vector

// A ray is described by an origin point, and a 
// directional (unit) vector.
define Ray as { Point origin, Vector direction }

public Ray Ray(Point origin, Vector direction):
    return { origin: origin, direction: direction }
