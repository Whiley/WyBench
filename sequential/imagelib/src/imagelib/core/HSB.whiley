package imagelib.core

import imagelib.core.RGBA // shouldn't be necessary?

public define HSB as {
    real hue, 
    real saturation, 
    real brightness
}

public HSB HSB(real hue, real saturation, real brightness):
    return {
        hue: hue,
        saturation: saturation,
        brightness: brightness
    }

public RGBA toRGBA(HSB h):
    n,d = h.hue
    hi =  ((n/d)/60) % 6
    f = (h.hue/60.0) - ((n/d)/60)
    p = h.brightness*(1.0-(h.saturation))
    q = h.brightness*(1.0-(f*h.saturation))
    t = h.brightness*(1.0-((1.0-f)* h.saturation))
    v = h.brightness    
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
