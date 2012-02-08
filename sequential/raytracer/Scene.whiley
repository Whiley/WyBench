import Ray
import Colour
import Point
import Sphere
import Vector

define Scene as {
    [Sphere] objects,
    [Point] lights
}

public Scene Scene([Sphere] objects, [Point] lights):
    return { objects: objects, lights: lights }

public void ::render(Scene scene):
    v = Vector(0,0,1)
    for i in 0..Display.WIDTH:
        for j in 0..Display.HEIGHT:
            ray = Ray(Point(i,j,0),v)
            colour = rayCast(scene,ray)
            if colour != null:
                Display.draw(i,j,colour)
    // done

public Colour|null rayCast(Scene scene, Ray ray):
    for s in scene.objects:
        r = Sphere.intersect(s,ray)
        if r != null:
            return Colour.BLACK
    return null // no intersection