import Point
import Colour

public define Light as {
    Point point,
    Colour colour
}

public Light Light(Point point, Colour colour):
    return {
        point: point,
        colour: colour
    }

// Determine the color of this light at a given point in space.  That
// is, determine the light attenuation for this light between its 
// location and the given point.  As is common, this algorithm attenuates
// light using a formula where intensity is inversly proportional to
// distance.
public Colour colourAt(Light light, Point point):
    diff = Point.subtract(light.point,point)
    magnitude_sqr = Vector.dot(diff,diff)
    intensity = Math.min(1.0,1000.0 / magnitude_sqr)
    return Colour.dim(light.colour,intensity)