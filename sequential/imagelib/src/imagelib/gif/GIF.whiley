package imagelib.gif

import u8 from whiley.lang.Int
import u16 from whiley.lang.Int

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

define GIF87a_MAGIC as "GIF87a"
define GIF89a_MAGIC as "GIF89a"

// A GIF file
public define GIF as {
    string magic,
    u16 width,  // screen width
    u16 height, // screen height
    u8 background, // index of background colour
    ColourMap colourMap,
    [Image] images,
    [Extension] extensions
}

// Construct a GIF file with the given attributes
public GIF GIF(string magic, u16 width, u16 height, u8 background, 
            ColourMap colourMap, [Image] images, [Extension] extensions):
    return {
        magic: magic,
        width: width,
        height: height,
        background: background,
        colourMap: colourMap,
        images: images,
        extensions: extensions
    }

// An image descriptor within a GIF file
public define Image as {
    u16 left,
    u16 top,
    u16 width,
    u16 height,
    bool interlaced,
    ColourMap colourMap,
    [int] data
}

// Construct a GIF image with the given attributes.
public Image Image(u16 left, u16 top, u16 width, u16 height, bool interlaced, 
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
