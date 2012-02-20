// Copyright (c) 2011, David J. Pearce
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

package rt.core

import rt.util.*
import rt.objects.Sphere /// TO BE REMOVED

// A Scene is made up of zero or more objects, and zero or more light
// sources.  The position of the camera is also required.  However, 
// the viewing plane is currently assumed to be in the direction of the
// z-axis, and containing position 0,0,0
define Scene as {
    [Sphere] objects,
    [Light] lights,
    Colour ambient, // ambient light      
    Vector camera                         
}

public Scene Scene([Sphere] objects, [Light] lights, Colour ambient, Vector camera):
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
    ray.direction.z = -cam_z
    for i in 0 .. width:
        ray.direction.x = i - cam_x
        for j in 0 .. height:
            ray.direction.y = j - cam_y
            col = rayCast(scene,ray)
            pixels = pixels + [col]    
            debug "\r" + count + " / " + total
            count = count + 1
    // done
    return pixels

public Colour rayCast(Scene scene, Ray ray):
    mint = 1000000 // arbitrary
    obj = null
    // first, determine nearest object hit by ray
    for o in scene.objects:
        t = Sphere.intersect(o,ray)
        if t != null && t < mint:
            obj = o
            mint = t
    // second, determine light from that object
    if obj != null:
        pt = Ray.project(ray,mint) // intersection point
        return lightCast(scene,pt,obj)
    return Colour.BLACK

public Colour lightCast(Scene scene, Vector pt, Sphere h):
    colour = scene.ambient
    for light in scene.lights:
        ray = Ray(pt,Vector.subtract(light.point,pt))
        intersection = false
        // determine whether light obstructed by something
        for o in scene.objects:
            if h != o:
                t = Sphere.intersect(o,ray)
                if t != null && t > 0 && t < 1.0:
                    intersection = true
                    break
        if !intersection:
            // not obstructed
            c = Light.colourAt(light,pt)
            colour = Colour.blend(colour,c)
    return colour
