import rt.util.Colour

public define WIDTH as 256
public define HEIGHT as 256

public void ::paint([Colour] pixels):
    reds = []
    greens = []
    blues = []
    for p in pixels:
        reds = reds + [Math.round(p.red*255)]
        greens = greens + [Math.round(p.green*255)]
        blues = blues + [Math.round(p.blue*255)]
    paint(reds,greens,blues)

public native void ::paint([Int.u8] reds,[Int.u8] greens,[Int.u8] blues):
