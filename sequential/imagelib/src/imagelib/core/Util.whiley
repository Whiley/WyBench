package imagelib.core

define HSB as {real h, real s, real b}

public RGB HSBtoRGB(HSB h):
	n,d = h.h
	hi =  ((n/d)/60) % 6
	f = (h.h/60.0) - ((n/d)/60)
	p = h.b*(1.0-(h.s))
	q = h.b*(1.0-(f*h.s))
	t = h.b*(1.0-((1.0-f)* h.s))
	n,d = h.b
	v = n*255 / d
	n,d = p
	p = n*255 / d
	n,d = q
	q = n*255 / d
	n,d = t
	t = n*255 / d
	if hi == 0:
		return {r:v, g:t, b:p}
	else if hi == 1:
		return {r:q, g:v, b:p}
	else if hi == 2:
		return {r:p, g:v, b:t}
	else if hi == 3:
		return {r:p, g:q, b:v}
	else if hi == 4:
		return {r:t, g:p, b:v}
	else if hi == 5:
		return {r:v, g:p, b:q}
	return {r:0, g:0, b:0}

public HSB RGBtoHSB(RGB a):
	r = (real)a.r/255
	g = (real)a.g/255
	b = (real)a.b/255
	M = realMax(r, g)
	M = realMax(M, b)
	m = realMin(r, g)
	m = realMin(m, b)
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