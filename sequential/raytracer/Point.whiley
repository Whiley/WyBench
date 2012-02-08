public define Point as {
    real x,
    real y,
    real z
}

public Point Point(real x, real y, real z):
    return {x:x, y:y, z:z}

public Point subtract(Point p1, Point p2):
    return Point(p1.x-p2.x, p1.y-p2.y, p1.z-p2.z)

public string toString(Point p):
    return "(" + Real.toDecimal(p.x,5) + "," + Real.toDecimal(p.y,5) + "," + Real.toDecimal(p.z,5) + ")"
