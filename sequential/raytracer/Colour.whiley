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
