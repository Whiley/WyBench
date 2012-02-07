import * from whiley.lang.*

define RGB as {int r, int g, int b}

define HSB as {real h, real s, real b}

real realMax(real a, real b):
	if a >= b:
		return a
	else:
		return b
		
real realMin(real a, real b):
	if a <= b:
		return a
	else:
		return b

public HSB RGBtoHSB(RGB a):
	r = (real)a.r/255
	g = (real)a.g/255
	b = (real)a.b/255
	debug "R: " + r + " G: " + g + " B: " + b + "\n"
	M = realMax(r, g)
	M = realMax(M, b)
	m = realMin(r, g)
	m = realMin(m, b)
	debug "Max Value: " + M + "\n"
	debug "Min Value: " + m + "\n"
	chroma = M - m
	debug "Chroma: " + chroma + "\n"
	H = 0
	if chroma == 0:
		debug "CHROMA ZERO. ERROR?"
	else if M == r:
		val = (g-b)/chroma
		div = val/6
		debug "Val: " + val + " Div: " + div + "\n"
		if div <= 1:
			H = div
		else:
			//Have to Deal with Modulo Here
			divI = (int) div
		//H = ((g-b)/chroma) % 6
	else if M == g:
		H = ((b-r)/chroma) + 2
	else if M == b:
		H = ((r-g)/chroma) + 4
	else:
		debug "CONVERSION ERROR. M SHOULD HAVE BEEN CAUGHT"
	H = H * 60 
	debug "Hue: " + H + "\n"
	V = M // This forms the B
	S = 0
	if chroma != 0 && V != 0:
		S = chroma/V
	debug "Saturation: " + S + "\n"
	return {h: H, s: S, b: V}


void ::main(System.Console sys):
	rgb = {r:127, b:43, g: 96}
	sys.out.println(RGBtoHSB(rgb))