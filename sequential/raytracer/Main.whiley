import * from whiley.lang.System

import Point
import Sphere
import Scene
import Colour
import Light

void ::main(System.Console sys):
    start = Time.current()
    ambient = Colour(0.4,0.4,0.4)
    camera = Point(128,128,-100)
    s1 = Sphere(Point(70,70,30),15)
    s2 = Sphere(Point(50,20,50),30)
    s3 = Sphere(Point(60,160,50),30)
    l1 = Light(Point(100,100,0),Colour(1,0.75,0))
    scene = Scene([s1,s2,s3],[l1],ambient,camera)
    pixels = Scene.render(scene,Display.WIDTH,Display.HEIGHT)
    Display.paint(pixels)
    duration = Time.current() - start
    debug "\nTIME: " + Math.round(duration * 1000) + "ms"