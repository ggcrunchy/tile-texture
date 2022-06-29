--- Test for cap-style curves.

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

local Distance, Delta = 81.25, 20

local HermiteDistance, HermiteDelta = Distance * 4, Delta * 4

local Pos1, Tan1 = { x = CX + 100, y = CY }, { x = 0, y = HermiteDistance }
local Pos2, Tan2 = { x = CX - 100, y = CY }, { x = 0, y = -HermiteDistance }

--- DOCME
function M.Do ()
	for _ = 1, 3 do
		for i = 0, 10 do
			local x, y = curve.GetPosition("hermite", Pos1, Pos2, Tan1, Tan2, i / 10)
			local c = display.newCircle(x, y, 5)

			c:setFillColor(1, 0, 0)
			c:setStrokeColor(0, 1, 0, .4)

			c.strokeWidth = 2
		end

		Pos1.x, Tan1.y = Pos1.x - 20, Tan1.y - HermiteDelta
		Pos2.x, Tan2.y = Pos2.x + 20, Tan2.y + HermiteDelta
	end
end

--
--
--

return M