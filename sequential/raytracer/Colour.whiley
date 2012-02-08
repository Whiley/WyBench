import * from whiley.lang.Type

public define Colour as {
    uint8 red,
    uint8 green,
    uint8 blue
}

public define BLACK as { red: 0, green: 0, blue: 0 }
public define WHITE as { red: 255, green: 255, blue: 255 }

public Colour Colour(uint8 red, uint8 green, uint8 blue):
    return {red:red, green:green, blue:blue}
