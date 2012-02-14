import RGB from Color

define Image as {
    [RGB] data,
    int width,
    int height
} where (width*height) == |data|

public Image Image(int width, int height, [RGB] data) requires (width*height) == |data|:
    return {
        width: width, 
        height: height,
        data: data
    }