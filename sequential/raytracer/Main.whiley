import * from whiley.lang.System

import Point
import Sphere
import Scene

void ::main(System.Console sys):
    s1 = Sphere(Point(100,100,0),50)
    s2 = Sphere(Point(400,400,0),20)
    l1 = Point(10,10,10)
    scene = Scene([s1,s2],[l1])
    Scene.render(scene)