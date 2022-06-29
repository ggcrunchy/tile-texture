--- Build the tile texture mesh.

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
local options = require("options")
local mesh = require("tile_texture.mesh")

-- Exports --
local M = {}

--
--
--

--- DOCME
function M.Do ()
	local X1, Y1 = 50, 50

	local X2, Y2 = display.contentWidth - X1, display.contentHeight - Y1

	local CellW, CellH = math.ceil((X2 - X1) / 4), math.ceil((Y2 - Y1) / 4)

	---[[

	-- Make cell dimensions equal:

	local d = math.min(CellW, CellH)

	CellW, CellH = d, d

	X1, Y1 = math.ceil((display.contentWidth - 4 * d) / 2), math.ceil((display.contentHeight - 4 * d) / 2)

	X2, Y2 = display.contentWidth - X1, display.contentHeight - Y1

	--]]

	local NormalsGroup = options.ShowNormals and display.newGroup()

	local function ShowGrid ()
		local x, y = X1, Y1

		for _ = 1, 5 do
			local horz = display.newLine(X1, y, X2, y)
			local vert = display.newLine(x, Y1, x, Y2)

			horz.strokeWidth, vert.strokeWidth, x, y = 2, 2, x + CellW, y + CellH
		end
	end

	local ShowGridWhere = "below"

	if ShowGridWhere == "below" then
		ShowGrid()
	end

	local indices, knots, normals, verts = mesh.Build{
		quad_count_along_axis = 20,
		layer_count = 16,
		slice_count = 15,

		grow_fraction = .625,
		horizontal_tangent_scale = .825, vertical_tangent_scale = .825,
		cell_width = CellW, cell_height = CellH,
		diameter_fraction = .7,

		arc_callback = options.ArcCallback, cap_callback = options.CapCallback, edge_callback = options.EdgeCallback, triangle_callback = options.TriangleCallback,

		normals_group = NormalsGroup
	}

	local mesh = display.newMesh{ indices = indices, uvs = options.SetUVs(normals, knots), vertices = verts, mode = "indexed" }

	mesh.x, mesh.y, mesh.fill.effect = display.contentCenterX, display.contentCenterY, options.Effect

	if NormalsGroup then
		NormalsGroup:toFront()
	end

	if ShowGridWhere == "above" then
		ShowGrid()
	end
end

--
--
--

return M