package imagelib.transforms

import imagelib.core.Image
import imagelib.core.RGBA
import imagelib.core.HSB

public Image brighten(Image img, int factor):
	
	for i in 0..|img.data|:
		hs = RGBA.toHSB(img.data[i])
		hs.brightness = Math.min(1.0, hs.brightness*factor)
		img.data[i] = HSB.toRGBA(hs)
	
	return img
