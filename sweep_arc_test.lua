--- Test for sweep-style curves.

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
local curve = require("spline_ops.cubic.curve")

-- Exports --
local M = {}

--
--
--

local CX, CY = display.contentCenterX, display.contentCenterY - 100

local Pos1, Tan1 = { x = CX + 350, y = CY }, { x = 0, y = 0 }
local Pos2, Tan2 = { x = CX + 100, y = CY + 250 }, { x = 0, y = 0 }

local Kx, Ky = .7, .7

local LayerCount, AxisCount = 7, 13

--- DOCME
function M.Do ()
	local x1, y1, x2, y2 = Pos1.x, Pos1.y, Pos2.x, Pos2.y

	for _ = 1, LayerCount do
		-- cf. GetCurveValues in swept_arc; the details differ slightly, but the central ideas are the same
		local ox, oy = x1 + Kx * (x2 - x1), y2 - Ky * (y2 - y1)
		local mx, my = (x1 + x2) / 2, (y1 + y2) / 2

		Pos1.y, Tan1.x = y1, 8 * (ox - mx)
		Pos2.x, Tan2.y = x2, 8 * (my - oy)

		for i = 0, AxisCount do
			local x, y = curve.GetPosition("hermite", Pos1, Pos2, Tan1, Tan2, i / AxisCount)
			local c = display.newCircle(x, y, 3)

			c:setFillColor(1, 0, 0)
			c:setStrokeColor(0, 1, 0, .4)

			c.strokeWidth = 2
		end

		y1, x2 = y1 + 10, x2 + 20
	end
end

--
--
--

return M