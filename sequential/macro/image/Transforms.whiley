import * from whiley.lang.*
import RGB from Util


public [[RGB]] brighten([[RGB]] array, int coeff):
	for i in 0..|array|:
		for j in 0..|array[0]|:
			rgb = array[i][j]
			rgb.r = Util.mathMin(255, rgb.r+coeff)
			rgb.g = Util.mathMin(255, rgb.g+coeff)
			rgb.b = Util.mathMin(255, rgb.b+coeff)
			array[i][j] = rgb
	return array

