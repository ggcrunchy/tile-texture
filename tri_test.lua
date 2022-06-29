--- Test for triangle generation.

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

-- Exports --
local M = {}

--
--
--

local Above = {}

local function NoOp () end

--- DOCME
function M.Do (ledge, redge, bedge, index, test_print)
	test_print = test_print or NoOp

	local n, above = #redge, ledge

	assert(#ledge == n and n == #bedge)
	assert(ledge[1] == bedge[1])
	assert(ledge[n] == redge[1])
	assert(redge[n] == bedge[n])

	for i = 1, n - 1 do
		local ul = above[2] -- 1 = corner (not updated); 2 and up row above

		test_print("TRI1", bedge[i], ul, bedge[i + 1])

		local ll, lr = bedge[i + 1]

		for j = 2, n - i do
			local ur = above[j + 1]

			if j + i < n then -- not last in row?
				index = index + 1 -- new point (pos and uv should interpolate...)
				lr = index
			else
				lr = redge[i + 1]
			end

			test_print("QUAD1", ul, ur, ll, lr)

			ll, ul, Above[j] = lr, ur, lr -- put lower-right corner into "above" row for next pass
		end

		Above[n], above = lr, Above -- after first pass, use internal buffer as "above" row
	end

	test_print("")
end

--
--
--

return M