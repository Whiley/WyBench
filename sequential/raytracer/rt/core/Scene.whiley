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

import rt.core.Ray
import rt.core.Point
import rt.core.Sphere
import rt.core.Vector
import rt.core.Light
import rt.uril.Colour

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
    pixels = []
    total = width*height
    count = 0
    for i in 0 .. width:
        for j in 0 .. height:
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
