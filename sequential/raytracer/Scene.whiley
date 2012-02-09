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
            entry,exit = r
            i = lightCast(scene,entry,s)
            return Colour(i,i,i)
    return null // no intersection

public real lightCast(Scene scene, Point pt, Sphere h):
    intensity = 0.0
    for s in scene.lights:
        ray = Ray(pt,Point.subtract(s,pt))
        intersection = false
        // determine whether light obstructed by something
        for o in scene.objects:
            if h != o:
                r = Sphere.intersect(o,ray)
                if r != null:
                    intersection = true
                    break
        if !intersection:
            // not obstructed
            magnitude = Vector.length(ray.direction) / 100            
            i = 1.0 / magnitude
            intensity = Math.min(1.0,intensity + i)
    return intensity            
