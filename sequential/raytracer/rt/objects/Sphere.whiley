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

package rt.objects

import rt.core.*
import rt.util.*

// A Sphere is the simplest object to ray trace.  If we have a sphere
// of radius r centered at position c, then any point p on the sphere
// must satisfy |p-c|^2 - r^2 = 0
define Sphere as {
    Vector origin,
    real radius,
    real radius2
}

public Sphere Sphere(Vector origin, real radius):
    return { 
        origin: origin,
        radius: radius,
        radius2: radius * radius // useful
    }

// Determine whether the given vector intersects the 
// given box.  When there is an intersection there will 
// be an entry and exit point.  This function returns 
// these or null if there is no intersection.
public null|(Vector,Vector) intersect(Sphere s, Ray r):
    // transform into object space
    rOrigin = Vector.subtract(r.origin, s.origin)
    
    // Find solutions for x in a quadratric equation of the form:
    //
    //  Ax^2 + Bx + C = 0.  
    //    
    // This is of course a classic problem and there are not 
    // necessarily any real solutions.  This method will only return
    // return solutions, or null if there are none.
    //
    // yes, it's ugly.  That's because I'm carefully trying to reduce
    // the number of arithmetic operations involved.

    rdir = r.direction
    rdir_x = rdir.x    
    rdir_y = rdir.y    
    rdir_z = rdir.z
    rorg_x = rOrigin.x
    rorg_y = rOrigin.y
    rorg_z = rOrigin.z
    
    A = rdir_x*rdir_x + rdir_y*rdir_y + rdir_z*rdir_z    
    B = rorg_x*rdir_x + rorg_y*rdir_y + rorg_z*rdir_z
    B = B + B
    C = rorg_x*rorg_x + rorg_y*rorg_y + rorg_z*rorg_z
    C = C - s.radius2

    discriminant = (B*B) - 4*A*C
    
    if discriminant < 0:
        // no real roots (implies no solutions)
        return null

    // HACK
    discriminant = Math.round(discriminant * 100) / 100.0    
    root = Math.sqrt(discriminant,0.001)
        
    _2A = 2*A
    t0 = (-B - root) /_2A
    t1 = (-B + root) / _2A
    
    return project(r,t0),project(r,t1)
   
// project a given ray by a certain amount of distance
public Vector project(Ray ray, real dist):
    d = ray.direction
    o = ray.origin
    x = (d.x * dist) + o.x
    y = (d.y * dist) + o.y
    z = (d.z * dist) + o.z
    return Vector(x,y,z)
