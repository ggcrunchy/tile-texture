--- Entry point.

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

-- Standard library imports --
local assert = assert

-- Modules --
local options = require("options")
local triangle = require("tile_texture.triangle")

--
--
--

display.setDefault("isShaderCompilerVerbose", true)
--
--
--

if options.IsWireframe then
	display.setDrawMode("wireframe")
end

--
--
--

local DoBuild = true
				--false

if DoBuild then

	local build = require("build")

	build.Do()

else

	--
	--
	--

	local swept_arc_setup = require("swept_arc_setup")

	local QuadCountAlongAxis = 20 -- cf. assertion in next section

	local Knots, Normals, Verts = {}, {}, {}

	local LayerCount = 16

	local ArcX, ArcY = display.contentCenterX, display.contentCenterY

	swept_arc_setup.Do(QuadCountAlongAxis, LayerCount, Knots, Normals, Verts, ArcX, ArcY)

	--
	--
	--

	--  +--------+--------+--------+--------*--------+--------+--------+--------+
	--  |        |        |        |        *        |        |        |        |
	--  |        |        |        |        *        |        |        |        |
	--  |        |        |        |        *        |        |        |        |
	--  +--------+--------+--------+--------*--------+--------+--------+--------+

	assert(QuadCountAlongAxis % 2 == 0, "Need even quad count to have a middle vertex")

	local MiddleVertexIndex = QuadCountAlongAxis / 2 + 1 -- cf. the starred column in the above diagram

	local Left, Right, Bottom, UniqueEdgeIndicesCount = triangle.Indices(MiddleVertexIndex)

	--
	--
	--

	local tri_test = require("tri_test")

	local LogTriTest = false

	tri_test.Do(Left, Right, Bottom, UniqueEdgeIndicesCount, LogTriTest and print)

	--
	--
	--

	local MeshShift1 = 70 -- since our tests have separate meshes, correction to align flush with swept arc
	local MeshShift2 = 46 -- if testing a half-width arc, use this correction instead

	local ShowTrianglesTest = true

	if ShowTrianglesTest then

		local triangles_test = require("triangles_test")

		local LogShowTrianglesTest = false

		local indices1, _ = triangles_test.Do(QuadCountAlongAxis, Knots, Normals, Verts, Left, Right, Bottom, ArcX, ArcY, MeshShift1, MeshShift2, UniqueEdgeIndicesCount, LogShowTrianglesTest and print)

		--
		--
		--

		local LogIndices = false

		if LogIndices then

			triangles_test.LogIndices(indices1, 1, QuadCountAlongAxis / 2)

		end

	end

	--
	--
	--

	local ShowLineTest = true

	if ShowLineTest then

		local line_test = require("line_test")

		local LineKnots, LineNormals, LineVerts = {}, {}, {}

		line_test.Do(QuadCountAlongAxis, LayerCount, LineKnots, LineNormals, LineVerts, ArcX - 300, ArcY)

	end

	--
	--
	--

	local ShowCapTest = true

	if ShowCapTest then

		local cap_test = require("cap_test")

		local LayerCount, SliceCount = 8, 13

		cap_test.Do(LayerCount, SliceCount, ArcX - MeshShift1 + 350, ArcY)

	end

	--
	--
	--

	local ShowCapArcs = false

	if ShowCapArcs then

		local cap_arc_test = require("cap_arc_test")

		cap_arc_test.Do()

	end

	--
	--
	--

	local ShowSweepArcs = false

	if ShowSweepArcs then

		local sweep_arc_test = require("sweep_arc_test")

		sweep_arc_test.Do()

	end

--
--
--

end