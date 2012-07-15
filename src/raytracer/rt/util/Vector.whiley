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

public define Vector as {
    real x,
    real y,
    real z
}

define ERROR as 0.001

public Vector Vector(real x, real y, real z):
    return { x:x, y:y, z:z }

// Return a unit vector pointing in the same direction as the
// original.
public Vector Unit(real x, real y, real z):
    sum = (x*x) + (y*y) + (z*z)
    sum = Math.round(sum * 100) / 100.0        
    len = Math.sqrt(sum,ERROR)
    return { 
        x: x / len,
        y: y / len,
        z: z / len
    }

// Determine the length (a.k.a magnitude) of a Vector
public real length(Vector a):
    sum = (a.x*a.x) + (a.y*a.y) + (a.z*a.z)

    // HACK    
    sum = Math.round(sum * 100) / 100.0        

    return Math.sqrt(sum,ERROR)

// Compute the so-called cross-produce of two Vectors
public Vector cross(Vector a, Vector b):
    x = (a.y*b.z) - (a.z*b.y)
    y = (a.z*b.x) - (a.x*b.z)
    z = (a.x*b.y) - (a.y*b.x)
    return { x:x, y:y, z:z }
   
// Compute the so-called dot-product of two Vectors
public real dot(Vector a, Vector b):
    return (a.x*b.x) + (a.y*b.y) + (a.z*b.z)

// Subtract one Vector from another
public Vector subtract(Vector v1, Vector v2):
    return { 
        x: v1.x - v2.x, 
        y: v1.y - v2.y, 
        z: v1.z - v2.z 
    }

// Convert a vector into a string
public string toString(Vector v):
    return "(" + Real.toDecimal(v.x,5) + "," + Real.toDecimal(v.y,5) + "," + Real.toDecimal(v.z,5) + ")"



