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
    Point origin,
    real radius
}

public Sphere Sphere(Point origin, real radius):
    return { 
        origin: origin,
        radius: radius 
    }

// Determine whether the given vector intersects the 
// given box.  When there is an intersection there will 
// be an entry and exit point.  This function returns 
// these or null if there is no intersection.
public null|(Point,Point) intersect(Sphere s, Ray r):
    // transform into object space
    rOrigin = Point.subtract(r.origin, s.origin)
    
    A = Vector.dot(r.direction, r.direction)
    B = 2 * Vector.dot(r.direction, rOrigin)
    C = Vector.dot(rOrigin,rOrigin) - (s.radius * s.radius)

    t = solveQuadratic(A,B,C,0.0001)    

    if t == null:
        // there is no intersection!
        return null
    t0,t1 = t

    return project(r,t0),project(r,t1)

// Find solutions for x in a quadratric equation of the form:
//
//  Ax^2 + Bx + C = 0.  
//
// This is of course a classic problem and there are not 
// necessarily any real solutions.  This method will only return
// return solutions, or null if there are none.
null|(real,real) solveQuadratic(real A, real B, real C, real err):
    discriminant = (B*B) - 4*A*C
    if discriminant < 0:
        // no real roots
        return null

    // HACK
    discriminant = Math.round(discriminant * 100) / 100.0    

    root = Math.sqrt(discriminant,err)
    
    _2A = 2*A
    t0 = (-B - root) / _2A
    t1 = (-B + root) / _2A
    return (t0,t1)
       
// project a given ray by a certain amount of distance
public Point project(Ray ray, real dist):
    d = ray.direction
    o = ray.origin
    x = (d.x * dist) + o.x
    y = (d.y * dist) + o.y
    z = (d.z * dist) + o.z
    return Point(x,y,z)
