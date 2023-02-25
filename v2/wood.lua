--- Wood effect.

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
  category = "generator", name = "wood",

  fragment = [[
    // Created by inigo quilez - iq/2013
    // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
    #if !defined(GL_ES) || defined(GL_FRAGMENT_PRECISION_HIGH)
        #define IQ_HASH(n) fract(sin(n) * 43758.5453)
    #else
        #define IQ_HASH(n) fract(sin(n) * 43.7585453)
    #endif

    // Created by inigo quilez - iq/2013
    // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
    P_POSITION float IQ (P_POSITION vec2 x)
    {
        P_POSITION vec2 p = floor(x);
        P_POSITION vec2 f = fract(x);

        f = f * f * (3.0 - 2.0 * f);

        P_POSITION float n = p.x + p.y * 57.0;

        return mix(mix(IQ_HASH(n +  0.0), IQ_HASH(n +  1.0), f.x),
                   mix(IQ_HASH(n + 57.0), IQ_HASH(n + 58.0), f.x), f.y);
    }

    // Simplex Noise by IQ
    P_POSITION vec2 IQ2 (P_POSITION vec2 p)
    {
        p = vec2(dot(p, vec2(127.1, 311.7)),
                 dot(p, vec2(269.5, 183.3)));

        return -1. + 2. * IQ_HASH(p);
    }

    P_POSITION float noise (P_POSITION vec2 p)
    {
        const P_POSITION float K1 = 0.366025404; // (sqrt(3) - 1) / 2;
        const P_POSITION float K2 = 0.211324865; // (3 - sqrt(3)) / 6;

        P_POSITION vec2 i = floor(p + (p.x + p.y) * K1);
        
        P_POSITION vec2 a = p - i + (i.x + i.y) * K2;
        P_POSITION vec2 o = (a.x > a.y) ? vec2(1., 0.) : vec2(0., 1.); // vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
        P_POSITION vec2 b = a - o + K2;
        P_POSITION vec2 c = a - 1. + 2. * K2;
        P_POSITION vec3 h = max(.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.);
        P_POSITION vec3 n = h * h * h * h * vec3(dot(a, IQ2(i)), dot(b, IQ2(i + o)), dot(c, IQ2(i + 1.)));

        return dot(n, vec3(70.0));
    }

    const P_POSITION mat2 NoiseMatrix = mat2(0.80,  0.60, -0.60,  0.80);

    P_POSITION float FBM4 (P_POSITION vec2 p)
    {
        P_POSITION float f = 0.0;

        f += 0.5000 * noise(p); p = NoiseMatrix * p * 2.02;
        f += 0.2500 * noise(p); p = NoiseMatrix * p * 2.03;
        f += 0.1250 * noise(p); p = NoiseMatrix * p * 2.01;
        f += 0.0625 * noise(p);

        return f;
    }
  
    #define FBM(uv) FBM4(uv * vec2(13.4, 7.1))

    P_COLOR vec3 Wood (P_UV vec2 uv)
    {
      return mix(vec3(0.390, 0.346, 0.190) * .797, vec3(0.390, 0.265, 0.192) * 2.7, FBM(uv));
    }

    P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
    {
      P_UV vec3 n = .9125 * vec3(uv, 0.);

      n.z = 1. - dot(n, n);

      P_UV vec3 color = Wood(vec2(FBM4(n.xy - n.zx * 1.75), FBM4(n.yz - n.zx * 1.75)));

      return vec4(pow(color, vec3(.675 + n.z * 1.3)), 1.);
    }
  ]]
}

local random = math.random

local function Modify (sources)
  local vs = sources.vertices

  for i = 1, #vs do
    vs[i] = vs[i] + random(-1, 1) * .5
  end
end

return { name = "generator.custom.wood", modify = Modify }