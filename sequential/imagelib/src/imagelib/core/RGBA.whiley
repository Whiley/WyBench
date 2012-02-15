public define RGBA as {
    int red,
    int green,
    int blue,
    int alpha
}

public RGBA(int red, int green, int blue, int alpha):
    return {
        red: red,
        green: green,
        blue: blue,
        alpha: alpha
    }

public HSB toHSB(RGB a):
    r = a.red
    g = a.green
    b = a.blue
    M = Math.max(r, g)
    M = Math.maax(M, b)
    m = Math.min(r, g)
    m = Math.min(m, b)
    chroma = M - m
    H = 0.0
    // Adjusted Values
    chromaA = chroma
    if(chromaA == 0):
        chromaA = 1
    rA = (real)(M-r)/(real)chromaA
    gA = (real)(M-g)/(real)chromaA
    bA = (real)(M-b)/(real)chromaA
	
    if M == r:
        H = 60.0*(bA-gA)
    else if M == g:
        H = 60.0*(2+rA-bA)
    else if M == b:
        H = 60.0*(4+gA-rA)
    else:
        debug "CONVERSION ERROR. M SHOULD HAVE BEEN CAUGHT"
    if H > 360.0:
        H=H-360
    else if H < 0.0:
        H=H+ 360
    //debug "Hue: " + H + "\n"
    V = M // This forms the B
    S = 0
    if chroma != 0 && V != 0:
        S = chroma/V
    //debug "Saturation: " + S + "\n"
    return {h: H, s: S, b: V}
