import * from whiley.lang.Type

define normal as real where 0.0 <= $ && $ <= 1.0

public define Colour as {
    normal red,
    normal green,
    normal blue
}

public define BLACK as { red: 0.0, green: 0.0, blue: 0.0 }
public define WHITE as { red: 1.0, green: 1.0, blue: 1.0 }

public Colour Colour(normal red, normal green, normal blue):
    return {red:red, green:green, blue:blue}

// Combine two colours together
public Colour blend(Colour c1, Colour c2):
    red = Math.min(1.0,c1.red + c2.red)
    green = Math.min(1.0,c1.green + c2.green)
    blue = Math.min(1.0,c1.blue + c2.blue)
    return {
        red: red,
        green: green,
        blue: blue
    }

// Dim a given colour to a given intensity
public Colour dim(Colour colour, normal intensity):
    return {
        red: colour.red * intensity,
        green: colour.green * intensity,
        blue: colour.blue * intensity
    }
