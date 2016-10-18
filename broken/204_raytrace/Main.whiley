import * from whiley.lang.System

import rt.core.*
import rt.util.*
import rt.objects.*

void ::main(System.Console sys):
    start = Time.current()
    camera = Vector(128,128,-128)
    s1 = Sphere(Vector(80,80,30),15)
    s2 = Sphere(Vector(55,55,50),30)
    s3 = Sphere(Vector(125,125,30),15)
    l1 = Light(Vector(105,105,0),Colour(1,0.75,0))
    scene = Scene([s1,s2,s3],[l1],0.4,camera)
    pixels = Scene.render(scene,Display.WIDTH,Display.HEIGHT)
    pixels[(Math.round(l1.point.y)*Display.WIDTH)+Math.round(l1.point.x)] = Colour.WHITE
    Display.paint(pixels)
    duration = Time.current() - start
    debug "\nTIME: " + Math.round(duration * 1000) + "ms"
