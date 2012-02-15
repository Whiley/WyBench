package imagelib.core

define RGBA as {
    real red, 
    real green, 
    real blue, 
    real alpha
}

public RGBA RGBA(real red, real green, real blue, real alpha):
    return {
        red: red, 
        green: green,
        blue: blue,
        alpha: alpha
    }

define Image as {
    [RGBA] data,
    int width,
    int height
} where (width*height) == |data|

public Image Image(int width, int height, [RGBA] data) requires (width*height) == |data|:
    return {
        width: width, 
        height: height,
        data: data
    }