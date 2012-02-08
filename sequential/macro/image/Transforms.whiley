import * from whiley.lang.*
import RGB from Color

public [[RGB]] adjustHue([[RGB]] array, int factor):
	return array
public [[RGB]] contrast([[RGB]] array, int factor):
	
	return array

public [[RGB]] brighten([[RGB]] array, int coeff):
	for i in 0..|array|:
		for j in 0..|array[0]|:
			hs = Color.RGBtoHSB(array[i][j])
			hs.b = Util.realMin(1.0, hs.b*coeff)
			array[i][j] = Color.HSBtoRGB(hs)
	return array

public [[RGB]] adjustSaturation([[RGB]] array, int factor):
	return array

