define HSB as {real h, real s, real b}

public RGBA toRGBA(HSB h):
    n,d = h.h
    hi =  ((n/d)/60) % 6
    f = (h.h/60.0) - ((n/d)/60)
    p = h.b*(1.0-(h.s))
    q = h.b*(1.0-(f*h.s))
    t = h.b*(1.0-((1.0-f)* h.s))
    v = h.b    
    if hi == 0:
        return {red:v, green:t, blue:p, alpha:0.0}
    else if hi == 1:
        return {red:q, green:v, blue:p, alpha:0.0}
    else if hi == 2:
        return {red:p, green:v, blue:t, alpha:0.0}
    else if hi == 3:
        return {red:p, green:q, blue:v, alpha:0.0}
    else if hi == 4:
        return {red:t, green:p, blue:v, alpha:0.0}
    else if hi == 5:
        return {red:v, green:p, blue:q, alpha:0.0}
    return {red:0, green:0, blue:0, alpha:0.0}
