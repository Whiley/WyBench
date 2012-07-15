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

import * from whiley.lang.Type

define normal as real where 0.0 <= $ && $ <= 1.0

public define Colour as {
    normal red,
    normal green,
    normal blue
}

public define BLACK as { red: 0.0, green: 0.0, blue: 0.0 }
public define WHITE as { red: 1.0, green: 1.0, blue: 1.0 }

public Colour Colour(normal red, normal green, normal blue):
    return {red:red, green:green, blue:blue}

// Combine two colours together
public Colour blend(Colour c1, Colour c2):
    red = Math.min(1.0,c1.red + c2.red)
    green = Math.min(1.0,c1.green + c2.green)
    blue = Math.min(1.0,c1.blue + c2.blue)
    return {
        red: red,
        green: green,
        blue: blue
    }

// Dim a given colour to a given intensity
public Colour dim(Colour colour, normal intensity):
    return {
        red: colour.red * intensity,
        green: colour.green * intensity,
        blue: colour.blue * intensity
    }
