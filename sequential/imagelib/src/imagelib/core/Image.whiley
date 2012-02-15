package imagelib.core

import imagelib.core.RGBA // should be unnecessary?

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