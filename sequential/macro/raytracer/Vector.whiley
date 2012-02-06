define Vector as [real]

public real length(Vector v1):
    sum = 0.0
    for a in v1:
        sum = sum + (a*a)
    return Math.sqrt(sum)

public Vector cross(Vector v1, Vector v2):
    return v1 // TEMPORARY

public real dot(Vector v1, Vector v2) requires |v1| == |v2|:
    sum = 0.0
    for i in 0..|v1|:
        sum = sum + (v1[i]*v2[i])
    return sum



