--- Cap test.

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
local cap = require("tile_texture.cap")
local indexed = require("solar2d_utils.indexed")
local options = require("options")

-- Exports --
local M = {}

--
--
--

--- DOCME
function M.Do (layer_count, slice_count, cx, cy)
	local builder, state = indexed.NewLatticeBuilder(slice_count), cap.NewState()
	local knots, normals, verts = {}, {}, {}

	state:SetVertexAndStep(0, 0, 18.75, 0)
	state:SetDisplacementToTip(0, 1, 30, 22.5)
	state:SetOrientation("clockwise")

	state{
		builder = builder,
		into_knots = knots, into_normals = normals, into_vertices = verts,
		layer_count = layer_count
	}

	local indices = builder:GetResult()
	local mesh = display.newMesh{ indices = indices, uvs = options.SetUVs(normals, knots), vertices = verts, mode = "indexed" }

	mesh.x, mesh.y, mesh.fill.effect = cx, cy, options.Effect
end

--
--
--

return M