define Box as (
    int x1,
    int y1,
    int z1,
    int x2,
    int y2,
    int z2,
)

// Determine whether the given vector intersects the 
// given box.  When there is an intersection there will 
// be an entry and exit point.  This function returns 
// the entry point, or null if there is no intersection.
null|Point intersection(Box b, Vector v):
    return null

