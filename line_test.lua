--- Line test.

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

-- Modules --
local indexed = require("solar2d_utils.indexed")
local options = require("options")
local swept_arc = require("tile_texture.swept_arc")

-- Exports --
local M = {}

--
--
--

local X, Y1, Y2 = 0, 0, 200

local XStep = -8.5

function M.Do (quad_count_along_axis, layer_count, knots, normals, verts, cx, cy)
	local builder, state = indexed.NewLatticeBuilder(quad_count_along_axis), swept_arc.NewState()

	state:SetLayerCount(layer_count)
	state:SetOrientation("clockwise")

	state:SetKnots1(0, 0)
	state:SetLineVertexAndStep1(X, Y1, XStep, 0)

	state:SetKnots2(1, 1)
	state:SetLineVertexAndStep2(X, Y2, XStep, 0)

	state{
		builder = builder,
		into_knots = knots, into_normals = normals, into_vertices = verts,
		is_half_arc = options.IsHalfArc
	}

	local indices, _ = builder:GetResult()
	local mesh = display.newMesh{ indices = indices, uvs = options.SetUVs(normals, knots), vertices = verts, mode = "indexed" }

	mesh.x, mesh.y, mesh.fill.effect = cx, cy, options.Effect
end

--
--
--

return M