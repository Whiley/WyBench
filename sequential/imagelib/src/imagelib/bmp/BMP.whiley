package imagelib.bmp

import u8 from whiley.lang.Int
import u16 from whiley.lang.Int

import imagelib.core.Image
import imagelib.core.RGBA

public define BMPHeader as {
	int size, // Total Size of the BMP,
	int offset
	}

define DIBHeader as {
	int size, 
	int width,
	int height,
	int colorPlanes, // Should Always be one
	int bitsPerPixel,
	int compression, 
	int imageSize, 
	int horizontalResolution,
	int verticalResolution, 
	int colors,
	int importantColors
	}
	
public define BMP as {
	string magic, //BM
	BMPHeader header,
	DIBHeader dib,
	[int] data
	}

public BMP BMP(BMPHeader header, DIBHeader dib, [int] data):
	return {
	magic: "BM",
	header: header, 
	dib: dib,
	data: data}
	
public BMPHeader BMPHeader(int size, int offset):
	return {
	size: size,
	offset: offset
	}
	
public DIBHeader DIBHeader(int size, int width, int height, int bitsPerPixel, int ImageSize):
	return {
	size: size,
	width: width,
	height: height,
	colorPlanes: 1,
	bitsPerPixel: bitsPerPixel,
	compression: 0,
	imageSize: ImageSize,
	horizontalResolution: 2834,
	verticalResolution: 2834,
	colors: 0,
	importantColors: 0
	}
	
public Image toImage(BMP bmp):
	rgb = []
	i = 0
	while i < |bmp.data|:
		red = ((real)bmp.data[i]) / 255
		green = ((real)bmp.data[i+1]) / 255
		blue = ((real)bmp.data[i+2]) / 255
		i = i+3
		rgb = rgb + [RGBA(red, green, blue, 1.0)]
	return {
	width: bmp.dib.width,
	height: bmp.dib.height,
	data: rgb
	}