import * from whiley.lang.System

import Point
import Sphere
import Scene

void ::main(System.Console sys):
    c = Point(64,64,-100)
    s1 = Sphere(Point(20,34,40),10)
    s2 = Sphere(Point(40,40,40),15)
    l1 = Point(10,10,20)
    scene = Scene([s1,s2],[l1],c)
    pixels = Scene.render(scene,Display.WIDTH,Display.HEIGHT)
    Display.paint(pixels)