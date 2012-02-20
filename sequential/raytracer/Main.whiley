import * from whiley.lang.System

import rt.core.*
import rt.util.*
import rt.objects.*

void ::main(System.Console sys):
    start = Time.current()
    ambient = Colour(0.4,0.4,0.4)
    camera = Vector(128,128,-128)
    s1 = Sphere(Vector(75,75,30),15)
    s2 = Sphere(Vector(50,0,50),30)
    s3 = Sphere(Vector(125,125,30),15)
    l1 = Light(Vector(100,100,30),Colour(1,0.75,0))
    scene = Scene([s1,s2,s3],[l1],ambient,camera)
    pixels = Scene.render(scene,Display.WIDTH,Display.HEIGHT)
    pixels[(100*Display.WIDTH)+100] = Colour.WHITE
    Display.paint(pixels)
    duration = Time.current() - start
    debug "\nTIME: " + Math.round(duration * 1000) + "ms"
