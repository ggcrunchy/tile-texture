--- Astral effect.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

graphics.defineEffect{
  category = "generator", name = "astral",

  isTimeDependent = true,

  vertexData = {
    { index = 0, name = "x", default = 0 },
    { index = 1, name = "y", default = .25 },
    { index = 2, name = "z", default = .5 },
    { index = 3, name = "w", default = .75 }
  },

  fragment = [[
P_UV float sdStar(P_UV vec2 p, P_UV float r, P_UV float n, P_UV float m)
{
    // next 4 lines can be precomputed for a given shape
    P_UV float an = 3.141593/n;
    P_UV float en = 3.141593/m;  // m is between 2 and n
    P_UV vec2  acs = vec2(cos(an),sin(an));
    P_UV vec2  ecs = vec2(cos(en),sin(en)); // ecs=vec2(0,1) for regular polygon

    P_UV float bn = mod(atan(p.x,p.y),2.0*an) - an;
    p = length(p)*vec2(cos(bn),abs(sin(bn)));
    p -= r*acs;
    p += ecs*clamp( -dot(p,ecs), 0.0, r*acs.y/ecs.y);
    return smoothstep(.175, -.15, length(p)*sign(p.x));
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord ){
    P_UV float rr = mod(CoronaTotalTime * 1.7, 64.);
    P_UV float r1 = mod(CoronaTotalTime * .8 + rr, 12.);
    P_UV float f1 = -.75 + r1 / 10.;
    P_UV float r2 = mod(CoronaTotalTime * (3.4 + CoronaVertexUserData.x * 1.1), 7.9);
    P_UV float f2 = -.75 + r2 / 5.9;
    P_UV float r3 = mod(CoronaTotalTime * (.7 + CoronaVertexUserData.y * 1.2), 3.);
    P_UV float f3 = -.75 + r3 / 1.5;
    P_UV float r4 = mod(CoronaTotalTime * (1.9 + CoronaVertexUserData.z * .7), 5.);
    P_UV float f4 = -.75 + r4 / 3.3;
    P_UV float r5 = mod(CoronaTotalTime * (1.9 + CoronaVertexUserData.w * 1.3), 5.7);
    P_UV float f5 = -.75 + r5 / 4.2;
    P_UV float r6 = mod(CoronaTotalTime * 3.5 + rr, 2.9);
    P_UV float f6 = -.75 + r6 / 1.7;
    
    P_UV float k = 0.;
    
    k += sdStar(vec2(mix(.25, .75, smoothstep(-.25, 1.15, f1)), f1) - texCoord, .0275, 11., 9.3);
    k += sdStar(vec2(mix(.05, .95, smoothstep(-.25, 1.15, f2)), f2) - texCoord, .05, 8., 7.3);
    k += sdStar(vec2(mix(.35, .875, smoothstep(-.25, 1.15, f3)), f3) - texCoord, .035, 14., 13.93);
    k += sdStar(vec2(mix(.75, .25, smoothstep(-.25, 1.15, f4)), f4) - texCoord, .015, 5., 4.3);
    k += sdStar(vec2(mix(.75, .175, smoothstep(-.25, 1.15, f5)), f5) - texCoord, .095, 7., 4.7);
    k += sdStar(vec2(mix(.925, .05, smoothstep(-.25, 1.15, f6)), f6) - texCoord, .025, 5., 4.3);
    
    P_UV float m = .0725 * smoothstep(.4875 / 1.414, .5 / 1.414, abs(texCoord.y - .5));
    
	return vec4(min(k * 1.5 + m, 1.), min(k * .875 + m, 1.), min(k + m, 1.), clamp(k * (1. - m), 0., 1.)) * smoothstep(1., 1. / 1.414, 1. - texCoord.y);
  }
  ]]
}

return { name = "generator.custom.astral" }