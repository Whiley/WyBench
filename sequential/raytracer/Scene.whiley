import Point
import Sphere

define Scene as {
    [Sphere] objects,
    [Point] lights
}

public Scene Scene([Sphere] objects, [Point] lights):
    return { objects: objects, lights: lights }

public void ::render(Scene scene):
    for i in 1..512:
        for j in 1..512:
            Display.draw(i,j,0,0,255)
