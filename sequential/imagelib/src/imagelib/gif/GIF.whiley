package imagelib.gif

import Error from whiley.lang.Errors
import u8 from whiley.lang.Int
import u16 from whiley.lang.Int

import imagelib.core.Image
import imagelib.core.RGBA

// A colour in a GIF file is an unsigned integer between 0..255.
public define Colour as {
    u8 red,
    u8 green,
    u8 blue
}

public Colour Colour(int red, int green, int blue):
    return {
        red: red, 
        green: green,
        blue: blue
    }

// Colour maps are an optional assignment of colour indices to rgb
// values.
define ColourMap as [Colour]|null

// Defines standard magic numbersx
define GIF87a_MAGIC as "GIF87a"
define GIF89a_MAGIC as "GIF89a"

// A GIF file
public define GIF as {
    string magic,
    u16 width,  // screen width
    u16 height, // screen height
    u8 background, // index of background colour
    ColourMap colourMap,
    [ImageDescriptor] images,
    [Extension] extensions
}

// Construct a GIF file with the given attributes
public GIF GIF(string magic, u16 width, u16 height, u8 background, 
            ColourMap colourMap, [ImageDescriptor] images, [Extension] extensions):
    return {
        magic: magic,
        width: width,
        height: height,
        background: background,
        colourMap: colourMap,
        images: images,
        extensions: extensions
    }

// Decode a GIF file from a give list of bytes
public GIF decode([byte] bytes) throws Error:
    return Decoder.decode(bytes)
    

// An image descriptor within a GIF file
public define ImageDescriptor as {
    u16 left,
    u16 top,
    u16 width,
    u16 height,
    bool interlaced,
    ColourMap colourMap,
    [int] data
}

// Construct a GIF image with the given attributes.
public ImageDescriptor ImageDescriptor(u16 left, u16 top, u16 width, u16 height, bool interlaced, 
                ColourMap colourMap, [int] data):
    return {
        left: left,
        top: top,
        width: width,
        height: height,
        interlaced: interlaced,
        colourMap: colourMap,
        data: data
    }

public define Extension as {
    int code,
    [byte] data
}

public Image toImage(GIF gif, ImageDescriptor img) throws {string msg}:
    colourMap = img.colourMap
    if colourMap == null:
        colourMap = gif.colourMap
    if colourMap == null:
        throw {msg: "BROKEN"}
    data = []
    for index in img.data:
        col = colourMap[index]
        red = ((real)col.red) / 255
        green = ((real)col.green) / 255
        blue = ((real)col.blue) / 255
        data = data + [RGBA(red,green,blue,1.0)]
    return {
        width: img.width,
        height: img.height,
        data: data
    }
