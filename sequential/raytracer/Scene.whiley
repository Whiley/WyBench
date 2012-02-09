import Ray
import Colour
import Point
import Sphere
import Vector

// A Scene is made up of zero or more objects, and zero or more light
// sources.  The position of the camera is also required.  However, 
// the viewing plane is currently assumed to be in the direction of the
// z-axis, and containing position 0,0,0
define Scene as {
    [Sphere] objects,
    [Point] lights,  
    Point camera                         
}

public Scene Scene([Sphere] objects, [Point] lights, Point camera):
    return { objects: objects, lights: lights, camera: camera }

public [Colour] ::render(Scene scene, int width, int height):
    pixels = []
    total = width*height
    count = 0
    for i in 0..width:
        for j in 0..height:
            vec = Point.subtract(Point(i,j,0),scene.camera)
            ray = Ray(scene.camera,vec)
            col = rayCast(scene,ray)
            pixels = pixels + [col]    
            debug "\r" + count + " / " + total
            count = count + 1
    // done
    return pixels

public Colour rayCast(Scene scene, Ray ray):
    for s in scene.objects:
        r = Sphere.intersect(s,ray)
        if r != null:
            entry,exit = r
            i = lightCast(scene,entry,s)
            return Colour(i,i,i)
    return Colour.BLACK

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
            magnitude = Vector.length(ray.direction) / 10
            i = 1.0 / magnitude
            intensity = Math.min(1.0,intensity + i)
    return intensity            
