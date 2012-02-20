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

package rt.util

import rt.core.Vector

// The plane is represented using the classical "plane equation" 
// where for any point x,y,z on the plane we have Ax+By+Cz+D=0.  
// Furthermore, the cooefficients are ensured to be normalised, 
// such that sqrt(A^2+B^2+C^2) = 1

define Plane as {
    real A,
    real B,
    real C,
    real D
}

// Construct a plane from three distinct points which lie on the
// plane.
public Plane Plane(Vector p1, Vector p2, Vector p3) requires p1 != p2 && p1 != p3 && p2 != p3:
    // first, compute the coefficients
    A = p1.y*(p2.z-p3.z) + p2.y*(p3.z-p1.z) + p3.y*(p1.z-p2.z)
    B = p1.z*(p2.x-p3.x) + p2.z*(p3.x-p1.x) + p3.z*(p1.x-p2.x)
    C = p1.x*(p2.y-p3.y) + p2.x*(p3.y-p1.y) + p3.x*(p1.y-p2.y)
    D = p1.x*((p2.y * p3.z) - (p3.y*p2.z)) + 
        p2.x*((p3.y * p1.z) - (p1.y*p3.z)) +
        p3.x*((p1.y * p2.z) - (p2.y*p1.z))
    // second, normalise them
    len = Math.sqrt(A*A + B*B + C*C,0.0001)
    return {A:A/len, B:B/len, C:C/len, D:-D}

// Determine the distance of a point from the plane.
public real distance(Plane pl, Vector pt):
    return (pt.x * pl.A) + (pt.y * pl.B) + (pt.z * pl.C) + pl.D

// Determine the intersection point of a vecctor and plane.  In the
// case that no intersection exists (i.e. they are parallel to each
// other) then null is returned.
public null|Vector intersection(Plane p, Vector v):
    return null // TODO

    
