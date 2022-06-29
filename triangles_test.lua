--- Arc-adjacent triangles test.

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
local triangle = require("tile_texture.triangle")

-- Exports --
local M = {}

--
--
--

--[[

	Analysis for knot:

	A = 0 or 1
	B = 1 - A

	* Case #1:
	
	 A - - A
	| \     \__
	|  \       \
	|   \       ½
	|    \     / \
	|     \   /   \_
	|	   \ /      \
	|       B        \
	|      / \        B
	|     /   \_      |
	|    /      \_    |
	|   /         \_  |
	|  /            \ |
	| /              \|
    ½ - - - - - - - - ½


	C = ½ or ??

	* Case #2:
	
	 A - - A
	| \     \__
	|  \       \
	|   \       ½
	|    \     / \
	|     \   /   \_
	|	   \ /      \
	|       B        \
	|      / \        B
	|     /   \_      |
	|    /      \_    |
	|   /         \_  |
	|  /            \ |
	| /              \|
    C - - - - - - - - ½


	The lower-left triangles might go as per the summary in the triangle module.

	Ideally set up so that curve "sides" line up (or do start, direction)

]]

--
--
--

local function NoOp () end

local function PointCount (nquads)
	return nquads + 1
end

local function PointComponentCount (npoints)
	return npoints * 2
end

--- DOCME
function M.Do (quad_count_along_axis, knots, normals, verts, left, right, bottom, cx, cy, mesh_shift1, mesh_shift2, unique_edge_indices_count, test_print)
	test_print = test_print or NoOp

	local state = triangle.NewState()
	local npoints, points_per_row = #knots, PointCount(quad_count_along_axis)
	local last_row_offset = npoints - points_per_row

	local half_quad_count = quad_count_along_axis / 2

	local builder1 = indexed.NewLatticeBuilder(half_quad_count)

	builder1:SetMaxIndex(unique_edge_indices_count)

	local knot2, normal2, vert2 = {}, {}, {}

	local half_quad_points = PointCount(half_quad_count)
	local last_row_midpoint_offset = last_row_offset + half_quad_points - 1
	local last_row_midpoint_pair_offset = PointComponentCount(last_row_midpoint_offset)

	local top_x, top_y = verts[last_row_midpoint_pair_offset + 1], verts[last_row_midpoint_pair_offset + 2]
	local top_nx, top_ny = normals[last_row_midpoint_pair_offset + 1], normals[last_row_midpoint_pair_offset + 2]
	local top_knot = knots[last_row_midpoint_offset + 1]

	local last_row_pair_offset, final_pair_component = PointComponentCount(last_row_offset), PointComponentCount(npoints)

	local lower_left_x, lower_left_y = verts[last_row_pair_offset + 1], verts[final_pair_component]
	local lower_left_knot = .5

	test_print("Lower Left", lower_left_x, lower_left_y)
	test_print("Top", top_x, top_y)

	state:LeftEdge{
		into_knots = knot2, into_normals = normal2, into_vertices = vert2,
		lower_left_x = lower_left_x, lower_left_y = lower_left_y,
		lower_left_nx = 0, lower_left_ny = -1,
		lower_left_knot = lower_left_knot,
		top_x = top_x, top_y = top_y,
		top_nx = top_nx, top_ny = top_ny,
		top_knot = top_knot,
		count = half_quad_count
	}

	state:RightEdge{
		from_knots = knots, into_knots = knot2,
		from_normals = normals, into_normals = normal2,
		from_vertices = verts, into_vertices = vert2,
		count = half_quad_count,
		midpoint_offset = last_row_midpoint_offset
	}

	local final_offset = #knot2 - 1
	local final_pair_offset = PointComponentCount(final_offset)

	local lower_right_x, lower_right_y = vert2[final_pair_offset + 1], vert2[final_pair_offset + 2]
	local lower_right_nx, lower_right_ny = normal2[final_pair_offset + 1], normal2[final_pair_offset + 2]
	local lower_right_knot = knot2[final_offset + 1]

	test_print("Lower Right", lower_right_x, lower_right_y)

	state:BottomEdge{
		into_knots = knot2, into_normals = normal2, into_vertices = vert2,
		lower_left_x = lower_left_x, lower_left_y = lower_left_y,
		lower_right_x = lower_right_x, lower_right_y = lower_right_y,
		lower_left_nx = 0, lower_left_ny = -1,
		lower_right_nx = lower_right_nx, lower_right_ny = lower_right_ny,
		lower_left_knot = lower_left_knot,
		lower_right_knot = lower_right_knot,
		count = half_quad_count
	}

	state:Populate(builder1, left, right, bottom, knot2, normal2, vert2, { no_normalize = not options.IsHalfArc })

	if options.IsSeparated then
		mesh_shift1 = mesh_shift1 + 1
	end

	local indices1, _ = builder1:GetResult()
	local mesh1 = display.newMesh{ indices = indices1, uvs = options.SetUVs(normal2, knot2), vertices = vert2, mode = "indexed" }

	mesh1.x, mesh1.y, mesh1.fill.effect = cx, cy + mesh_shift1, options.Effect

	--mesh1:scale(5, 5)

	local knot3, normal3, vert3 = {}, {}, {}

	for i = 1, PointComponentCount(half_quad_points) do -- copy for testing (apart from slight shift), but shared in real situation
		normal3[i], vert3[i] = normal2[i], vert2[i]
	end

	for i = 1, half_quad_points do
		knot3[i] = knot2[i]
	end

	-- "right": everything from nn backward...

	state:RightEdge{
		from_knots = knots, into_knots = knot3,
		from_normals = normals, into_normals = normal3,
		from_vertices = verts, into_vertices = vert3,
		count = half_quad_count,
		midpoint_offset = last_row_midpoint_offset,
		step = -1
	}

	-- "bottom": slight variant on previous case...

	local upper_left_x, upper_left_y = lower_left_x, verts[last_row_pair_offset + 2]

	state:BottomEdge{
		into_knots = knot3, into_normals = normal3, into_vertices = vert3,
		lower_left_x = lower_left_x, lower_left_y = lower_left_y,
		lower_right_x = upper_left_x, lower_right_y = upper_left_y,
		lower_left_knot = .5,
		lower_left_nx = 0, lower_left_ny = -1,
		lower_right_nx = normals[last_row_pair_offset + 1], lower_right_ny = normals[last_row_pair_offset + 2],
		lower_right_knot = 0,
		count = half_quad_count
	}

	local builder2 = indexed.NewLatticeBuilder(half_quad_count)

	builder2:SetMaxIndex(unique_edge_indices_count)

	state:Populate(builder2, left, right, bottom, knot3, normal3, vert3, { no_normalize = not options.IsHalfArc })

	local indices2, _ = builder2:GetResult()
	local mesh2 = display.newMesh{ indices = indices2, uvs = options.SetUVs(normal3, knot3), vertices = vert3, mode = "indexed" }
	local shift = options.IsArcEndHalfWide and mesh_shift2 or mesh_shift1

	mesh2.x, mesh2.y, mesh2.fill.effect = cx - shift, cy, options.Effect

	--mesh2:scale(5, 5)

	return indices1, indices2
end

--
--
--

--- DOCME (this should agree with tri_test.Do()'s results)
function M.LogIndices (indices, ii, n)
	print("")

	for r = 1, n do
		print("TRI2", indices[ii], indices[ii + 1], indices[ii + 2])

		ii = ii + 3

		for _ = r + 1, n do
			print("QUAD2", indices[ii], indices[ii + 3], indices[ii + 4], indices[ii + 5])

			ii = ii + 6
		end
	end
end

--
--
--

return M