package imagelib.core

define Image as {
    [Color.RGB] data,
    int width,
    int height
} where (width*height) == |data|

public Image Image(int width, int height, [Color.RGB] data) requires (width*height) == |data|:
    return {
        width: width, 
        height: height,
        data: data
    }