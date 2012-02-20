import Ray
import Colour
import Point
import Sphere
import * from Vector
import Light

// A Scene is made up of zero or more objects, and zero or more light
// sources.  The position of the camera is also required.  However, 
// the viewing plane is currently assumed to be in the direction of the
// z-axis, and containing position 0,0,0
define Scene as {
    [Sphere] objects,
    [Light] lights,
    Colour ambient, // ambient light      
    Point camera                         
}

public Scene Scene([Sphere] objects, [Light] lights, Colour ambient, Point camera):
    return { 
        objects: objects, 
        lights: lights, 
        ambient: ambient,
        camera: camera 
    }

public [Colour] ::render(Scene scene, int width, int height):
    cam_x = scene.camera.x
    cam_y = scene.camera.y
    cam_z = scene.camera.z
    pixels = []
    total = width*height
    count = 0
    
    // construct ray object to avoid lots of unnecessary creation
    vec = Vector(0,0,0)
    ray = Ray(scene.camera,vec)
    for i in 0 .. width:
        dx = i - cam_x
        for j in 0 .. height:
            dy = j - cam_y
            ray.direction = Vector.Unit(dx,dy,-cam_z)
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
            return lightCast(scene,entry,s)
    return Colour.BLACK

public Colour lightCast(Scene scene, Point pt, Sphere h):
    colour = scene.ambient
    for light in scene.lights:
        ray = Ray(pt,Point.subtract(light.point,pt))
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
            c = Light.colourAt(light,pt)
            colour = Colour.blend(colour,c)
    return colour
