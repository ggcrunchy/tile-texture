--- Bits that change according to what we want to test.

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

-- The following may be changed to try different things:

-- This determines what we want to do with our knots and normals. The current options are:
-- * "NormalShaded": The texture coordinates receive the normals, which are used to shade our objects with a given "light".
-- * "PackedNormalShaded": Our normals' components are converted from [-1, +1] floating-point numbers to [0, 255] integers.
-- These are packed together as a 16-bit value in texture coordinate y, then decoded in the vertex kernel. At this point,
-- everything is like "NormalShaded".
-- * "KnotToColor": Our [0, 1] knots are rendered to the red channel.
-- * "NormalToUV": Our texture coordinates again contain the normals, in [-1, +1]. After rescaling to [0, 1], these are
-- rendered in the red and green channels.
-- * "PackedNormalToUV": Like "NormalToUV", but our normals have gone through the process described in "PackedNormalShaded".
-- TODO: use the unit_exclusive machinery (see s3_utils.snippets) to pack (1024, 1024) values
-- TODO: convert (x, y) normals to (phi, theta) instead since our projection onto the z = 0 plane bunches up a lot of values, e.g. near-vertical ones
local DrawMode = "NormalShaded"

local Effect = --"BasicShading"
--"Wood"
"Metal"

-- Is one end of our cylinder half as wide as the other?
local IsArcEndHalfWide = false

-- Is the arc part of our object half a cylinder (an extruded semicircle) or a full one (full circles)?
-- This determines the corresponding normals.
local IsHalfArc = false

-- Are the (curved) triangles slightly separated from the arc? (testing feature)
local IsSeparated = false

-- Draw objects in wireframe? (testing feature)
local IsWireframe = false

-- Show normals on arcs and caps?
local ShowNormals = false

-- TODO
local WantArcCallback = true--false

-- TODO
local WantCapCallback = false

-- TODO
local WantEdgeCallback = true--false

-- TODO
local WantTriangleCallback = true-- false

--
--
--

-- The following callbacks are all written for the build, so assume shared edges for caps
-- (thus no midpoint), no right edges, etc.

local random, sqrt = math.random, math.sqrt

local ArcCallback, CapCallback, EdgeCallback, TriangleCallback

local Knots, Normals, Vertices

local function SetSources (knots, normals, vertices)
	Knots, Normals, Vertices = knots, normals, vertices
end

if WantArcCallback then

	local BoundaryJostleRange = 2.25
	local MinBoundaryJostle = -.5 * BoundaryJostleRange

	local NormalsJostleRange = .275
	local MinNormalsJostle = -.5 * NormalsJostleRange

	local on_boundary
-- TODO: stuff for half arcs?
	function ArcCallback (what, arg1, arg2, arg3, arg4)
		if what == "begin_arc" then -- arg1: knots, arg2: normals, arg3: vertices
			SetSources(arg1, arg2, arg3)
		elseif what == "end_arc" then
			SetSources(nil)
		elseif what == "curve" then -- arg1: offset, arg2: pair offset, arg3: curve index, arg4: curve count
		--	if arg3 > 1 and arg3 < arg4 then -- interior of curve?
				local nx, ny = Normals[arg2 + 1], Normals[arg2 + 2]

				if on_boundary then -- push the boundary out very slightly
					local jostle = MinBoundaryJostle + random() * BoundaryJostleRange

					Vertices[arg2 + 1], Vertices[arg2 + 2] = Vertices[arg2 + 1] + nx * jostle, Vertices[arg2 + 2] + ny * jostle
				else -- jostle the normals a bit
					local len = sqrt(nx^2 + ny^2 + 1e-8)

					nx, ny = nx + MinNormalsJostle + random() * NormalsJostleRange, ny + MinNormalsJostle + random() * NormalsJostleRange

					len = len / sqrt(nx^2 + ny^2 + 1e-8)

					Normals[arg2 + 1], Normals[arg2 + 2] = nx * len, ny * len
				end
		--	end
		elseif what == "layer" then -- arg1: layer index, arg2: layer count
			on_boundary = arg1 == 1 or arg1 == arg2
		end
	end

end

if WantCapCallback then

	local on_boundary

	function CapCallback (what, arg1, arg2, arg3, arg4)
		if what == "begin_arc" then -- arg1: knots, arg2: normals, arg3: vertices
			SetSources(arg1, arg2, arg3)
		elseif what == "end_arc" then
			SetSources(nil)
		elseif what == "curve" then -- arg1: offset, arg2: pair offset, arg3: curve index, arg4: curve count
			if on_boundary then
				-- plane-aligned normal jostle
			else
				-- typical normal jostle
			end
		elseif what == "layer" then -- arg1: layer index, arg2: layer count
			on_boundary = arg1 == 1
		end
	end

end

if WantEdgeCallback then

	local NormalsJostleRange = .275
	local MinNormalsJostle = -.5 * NormalsJostleRange

	local is_left_edge

	function EdgeCallback (what, arg1, arg2, arg3, arg4)
		if what:starts("begin") then -- arg1: knots, arg2: normals, arg3: vertices
			SetSources(arg1, arg2, arg3)

			is_left_edge = what == "begin_left_edge"
		elseif what:ends("end") then
			SetSources(nil)
		elseif what == "edge" then -- arg1: offset, arg2: pair offset, arg3: edge index, arg4: edge count
			local nx, ny = Normals[arg2 + 1], Normals[arg2 + 2]

			if arg3 == 1 or not is_left_edge then -- in the build, everything else is shared
				-- TODO: any shift of position
			end

			local len = sqrt(nx^2 + ny^2 + 1e-8)

			nx, ny = nx + MinNormalsJostle + random() * NormalsJostleRange, ny + MinNormalsJostle + random() * NormalsJostleRange

			len = len / sqrt(nx^2 + ny^2 + 1e-8)

			Normals[arg2 + 1], Normals[arg2 + 2] = nx * len, ny * len
		end
	end

end

if WantTriangleCallback then

	local JostleRange = .05
	local MinJostle = -.5 * JostleRange

	function TriangleCallback (what, arg1, arg2, arg3)
		if what == "begin_populate" then -- arg1: knots, arg2: normals, arg3: vertices
			SetSources(arg1, arg2, arg3)
		elseif what == "end_populate" then
			SetSources(nil)
		elseif what == "triangle" then -- arg1: offset, arg2: pair offset
			-- plane-aligned normal jostle

			local nx, ny = MinJostle + random() * JostleRange, MinJostle + random() * JostleRange

			Normals[arg2 + 1], Normals[arg2 + 2] = nx, ny -- assumed to be (0, 0, 1)
		end
	end

end

--
--
--

local includer = require("solar2d_utils.includer")
local iq = require("s3_utils.snippets.noise.iq")
--local unit_exclusive = require("s3_utils.snippets.operations.unit_inclusive")

local Kernel = { category = "generator", name = "uv" }

local AddPosVarying1, AddPosVarying2 = "", ""

local SetUVs

if DrawMode == "NormalShaded" or DrawMode == "PackedNormalShaded" then

AddPosVarying1 = [[
	varying P_POSITION vec2 v_Pos;

]]

AddPosVarying2 = [[
		v_Pos = pos;

]]

if Effect == "Metal" then

includer.AugmentKernels({
    requires = { iq.IQ1, iq.FBM4 },--, unit_exclusive.UNIT_PAIR },

    fragment = (AddPosVarying1 .. [[

	#define FBM(uv) FBM4((uv) * vec2(27.4, 23.2))
    #define AMBIENT vec3(.07)
    #define DIFFUSE .1
    #define SPEC_EXPONENT 11.7
    #define SURFACE vec3(.875, .9, .875)
    #define LIGHT_COLOR vec3(1.)
    #define REFLECTION .8

    P_UV float Env (P_UV vec3 ldir, P_UV vec3 n)
    {
        return IQ(reflect(ldir + vec3(FBM(n.xy * 13.7), FBM((n.xz - n.yy) * 11.9), FBM((n.yz - n.xx) * 14.3)), n).xy);
    }

    P_UV vec2 Lit (P_UV float nl, P_UV float nh, P_UV float spec)
    {
        P_UV float k = max(nl, 0.);

        return vec2(k, pow(max(nh, 0.) * sign(k), spec));
    }

	P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
	{
		#define CX %.4f
		#define CY %.4f
	
		P_UV vec3 n = vec3(uv, 0.);

		n.z = sqrt(max(1. - dot(n, n), 0.));

		P_POSITION vec3 p = vec3(CX, CY + 128. * sin(.7 * CoronaTotalTime), 0.);
		P_UV vec3 ldir = normalize(p - vec3(v_Pos, 32.));

        P_UV vec3 vn = normalize(vec3(CX, CY, 0.) - vec3(v_Pos, 32.));
        P_UV vec3 hn = normalize(vn + ldir);
        P_UV vec2 lv = Lit(dot(ldir, n), dot(hn, n), SPEC_EXPONENT);
        P_COLOR vec3 c = SURFACE * (AMBIENT + lv.x * DIFFUSE * LIGHT_COLOR + (lv.y * LIGHT_COLOR + REFLECTION * Env(ldir, n)));

        return vec4(clamp(c, 0., 1.), 1.);
	}
]]):format(display.contentCenterX, display.contentCenterY)

}, Kernel)

elseif Effect == "Wood" then

local Wood1, Wood2 = [[vec3(0.390, 0.346, 0.190) * .197]], [[vec3(0.390, 0.265, 0.192)]]

includer.AugmentKernels({
    requires = { iq.FBM4 },
    fragment = (AddPosVarying1 .. [[
		#define FBM(uv) FBM4(uv * vec2(13.4, 7.1))

		P_COLOR vec3 Wood (P_UV vec2 uv)
		{
			return mix(%s, %s, FBM(uv));
		}

		P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
		{
			P_UV vec3 n = vec3(uv, 0.);

			n.z = sqrt(max(1. - dot(n, n), 0.));
/*
			P_POSITION vec3 p = vec3(%.4f, %.4f + 128. * sin(.7 * CoronaTotalTime), 32.);
			P_UV vec3 u = normalize(p - vec3(v_Pos, 0.));

			TODO: can we bump map this?

*/
			P_UV vec3 color = Wood(vec2(FBM4(n.xy - n.zx * 1.75), FBM4(n.yz - n.zx * 1.75)));

			return vec4(color, 1.);
		}
]]):format(Wood1, Wood2, display.contentCenterX, display.contentCenterY)

}, Kernel)

else
	assert(Effect == "BasicShading", "Unknown effect")

Kernel.fragment = (AddPosVarying1 .. [[
	P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
	{
		P_UV vec3 n = vec3(uv, 0.);

		n.z = sqrt(max(1. - dot(n, n), 0.));

		P_POSITION vec3 p = vec3(%.4f, %.4f + 128. * sin(1.7 * CoronaTotalTime), 512.);
		P_UV vec3 u = normalize(p - vec3(v_Pos, 0.));

		return vec4(vec3(.12, .1, .1) + .35 * max(0., dot(u, n)), 1.);
	}
]]):format(display.contentCenterX, display.contentCenterY)

end

--[=[
effect.vertexData = {
    unit_exclusive.VertexDatum("center", 0, 0, 0),
	{ name = "col", index = 1, default = 0 },
	{ name = "row", index = 2, default = 0 },
    { name = "dim", index = 3 }
}
--]=]

	Kernel.isTimeDependent = true
elseif DrawMode == "NormalToUV" or DrawMode == "PackedNormalToUV" then
	Kernel.fragment = [[
		P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
		{
			return vec4(clamp(.5 * uv + .5, 0., 1.), 0., 1.);
		}
	]]
else
	assert(DrawMode == "KnotToColor", "Unknown draw mode")

	Kernel.vertex = [[
		varying P_POSITION float v_Knot;

		P_POSITION vec2 VertexKernel (P_POSITION vec2 pos)
		{
			v_Knot = v_TexCoord.y;

			return pos;
		}
	]]

	Kernel.fragment = [[
		P_POSITION varying float v_Knot;

		P_COLOR vec4 FragmentKernel (P_UV vec2 _)
		{
			return vec4(v_Knot, 0., 0., 1.);
		}
	]]

	function SetUVs (_, knots)
		local new, j = {}, 1

		for _, v in ipairs(knots) do
			new[j], new[j + 1], j = 0, v, j + 2
		end

		return new
	end
end

local DecodeNormal = ""

if DrawMode == "PackedNormalShaded" or DrawMode == "PackedNormalToUV" then

DecodeNormal = [[
		v_TexCoord.y = mod(CoronaTexCoord.x, 256.);
		v_TexCoord.x = (CoronaTexCoord.x - v_TexCoord.y) / 256.;

		v_TexCoord = (2. / 255.) * v_TexCoord - 1.;

]]

	local function CrunchNormalComponent (comp)
		comp = .5 * comp + .5
		comp = math.max(0, math.min(comp * 255, 255))

		return math.floor(comp)
	end

	function SetUVs (normals)
		local new = {}

		for i = 1, #normals, 2 do
			new[i], new[i + 1] = CrunchNormalComponent(normals[i]) * 256 + CrunchNormalComponent(normals[i + 1]), 0
		end

		return new
	end
end

if #AddPosVarying1 + #AddPosVarying2 + #DecodeNormal > 0 then

Kernel.vertex = AddPosVarying1 .. [[
	P_POSITION vec2 VertexKernel (P_POSITION vec2 pos)
	{
]] .. AddPosVarying2 .. DecodeNormal .. [[
		return pos;
	}
]]

end
--[[
-- uncomment to see concatenated results; random-looking snippet formatting above was some attempt at pretty printing :D
print("VERTEX")
print(Kernel.vertex)
print("")
print("FRAGMENT")
print(Kernel.fragment)
]]

graphics.defineEffect(Kernel)

return {
	IsArcEndHalfWide = IsArcEndHalfWide,
	IsHalfArc = IsHalfArc,
	IsSeparated = IsSeparated,
	IsWireframe = IsWireframe,
	ShowNormals = ShowNormals,

	ArcCallback = ArcCallback,
	CapCallback = CapCallback,
	EdgeCallback = EdgeCallback,
	TriangleCallback = TriangleCallback,

	Effect = "generator.custom.uv",

	SetUVs = SetUVs or function(normals)
		return normals
	end
}