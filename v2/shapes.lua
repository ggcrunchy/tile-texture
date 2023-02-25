--- Tile shapes.

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

-- Plugins --
local bit = require("plugin.bit")

-- Modules --
local sflags = require("shape_flags")
local sprims = require("shape_prims")

-- Cached module references --
local _Trapezoid_

-- Exports --
local M = {}

--
--
--

local PrevRow, CurRow = {}, {}

function M.GetFromPreviousRow (index)
  return index < PrevRow.n and PrevRow[index]
end

--
--
--

local NubEdgeFlags = sflags.DummyFirst + sflags.OmitLast + sflags.DoNormals + sflags.ReverseEdge

--
--
--

function M.Nub (sources, edge, nlayers, nouter, interp, flags)
  assert(interp, "Nub must use interpolator")

  --
  --
  --

  local left, right, lhalf = {}, {}, nlayers / 2

  for i = 1, lhalf do
    right[i] = edge[i]
  end

  local nright, nedge = #right, #edge

  for i = 1, nright do
    left[i] = edge[nedge - i + 1]
  end

  --
  --
  --

  _Trapezoid_(sources, left, right, nouter, interp, flags)

  --
  --
  --

  local n, is = PrevRow.n, sources.indices
  local ehalf, nhalf = (nedge + 1) / 2, (n + 1) / 2
  local x1, y1, u = sprims.GetPoint(sources, edge[ehalf])
  local x2, y2 = sprims.GetPoint(sources, PrevRow[nhalf])
  local nx, ny = sprims.GetEdgeNormal()

  sprims.SetEdgeNormal(0, 0)

  local mid_edge = sprims.Edge(sources, x1, y1, u, x2, y2, .5, lhalf + 1, bit.bor(flags or 0, NubEdgeFlags))

  sprims.SetEdgeNormal(nx, ny)

  mid_edge[1] = edge[ehalf]
  mid_edge[#mid_edge + 1] = PrevRow[nhalf]

  for i = 1, lhalf + 1 do
    sprims.AddIndexedTriangle(is, PrevRow[i], PrevRow[i + 1], mid_edge[i])
    sprims.AddIndexedTriangle(is, PrevRow[i + 1], mid_edge[i], mid_edge[i + 1])
    sprims.AddIndexedTriangle(is, mid_edge[i], PrevRow[n - i + 1], PrevRow[n - i])
    sprims.AddIndexedTriangle(is, mid_edge[i], mid_edge[i + 1], PrevRow[n - i])
  end
end

--
--
--

local function GetFirstRow ()
  local first = PrevRow.set and 2 or 1

  PrevRow.set = nil

  return first
end

--
--
--

function M.Rectangle (sources, left, right, cols, row)
  local is, vs, uvs, npoints = sources.indices, sources.vertices, sources.uvs, #left

  assert(npoints == #right, "Unbalanced rectangle edges")

  local first, nfunc, nx, ny = GetFirstRow(), sources.normals_func, sprims.GetEdgeNormal()

  row = row or first -- n.b. assumes first = 1 when row exists

  for i = first, npoints do
    local lx, ly, lu = sprims.GetPoint(sources, left[i])
    local rx, ry, ru = sprims.GetPoint(sources, right[i])

    --
    --
    --

    CurRow[1] = left[i]

    for j = 1, cols - 1 do
      CurRow[j + 1] = sprims.AddLerpedPair(vs, lx, ly, rx, ry, j / cols)

      if nfunc then
        nfunc("arc", nx, ny, i - 1, npoints - 1)
      end

      sprims.AddU(uvs, lu, ru, j / cols, true)
    end

    CurRow[cols + 1] = right[i]
    CurRow.n = cols + 1

    --
    --
    --

    if i > 1 then
      for j = 1, cols do
        sprims.AddIndexedTriangle(is, PrevRow[j], PrevRow[j + 1], CurRow[j])
        sprims.AddIndexedTriangle(is, CurRow[j], PrevRow[j + 1], CurRow[j + 1])
      end
    end

    --
    --
    --

    CurRow, PrevRow, row = PrevRow, CurRow, row + 1
  end
end

--
--
--

function M.SetPrevRow (edge, n)
  for i = 1, n or #edge do
    PrevRow[i] = edge[i]
  end

  PrevRow.n, PrevRow.set = n or #edge, true
end

--
--
--

local function DefInterp (sources, lx, ly, rx, ry, t)
  return sprims.AddLerpedPair(sources.vertices, lx, ly, rx, ry, t)
end

--
--
--

function M.Trapezoid (sources, left, right, ntop, interp, flags)
  interp = interp or DefInterp

  --
  --
  --

  local nlayers = #left

  assert(nlayers == #right, "Unbalanced trapezoid sides")

  ntop = ntop or nlayers

  assert(ntop >= nlayers)

  --
  --
  --

  local nfunc, ul = interp == DefInterp and sources.normals_func, left[1]
  local do_parabola = sflags.HasFlag(flags, "Parabola")
  local is, uvs, npoints = sources.indices, sources.uvs, ntop + 1

  for i = GetFirstRow(), nlayers do
    local lx, ly, lu = sprims.GetPoint(sources, left[i])
    local rx, ry, ru = sprims.GetPoint(sources, right[i])
    local w = npoints - i

    --
    --
    --

    CurRow[1] = left[i]

    for j = 1, w - 1 do
      local t = j / w

      if nfunc then
        nfunc("interior", j, w, i - 1, nlayers - 1, ul)
      end

      CurRow[j + 1] = interp(sources, lx, ly, rx, ry, t, i, nlayers)

      sprims.AddU(uvs, lu, ru, t, do_parabola)
    end

    CurRow[w + 1] = right[i]
    CurRow.n = w + 1

    --
    --
    --

    if i > 1 then
      for j = 1, w do
        sprims.AddIndexedTriangle(is, PrevRow[j], PrevRow[j + 1], CurRow[j])
      end
      
      for j = 1, w - 1 do
        sprims.AddIndexedTriangle(is, CurRow[j], PrevRow[j + 1], CurRow[j + 1])
      end

      sprims.AddIndexedTriangle(is, PrevRow[w + 1], right[i - 1], right[i])
      sprims.AddIndexedTriangle(is, CurRow[w], PrevRow[w + 1], right[i])
    end

    --
    --
    --

    CurRow, PrevRow = PrevRow, CurRow
  end
end

--
--
--

function M.Triangle (sources, left, right, mid, flags)
  local nlayers = #left

  _Trapezoid_(sources, left, right, nil, nil, flags)

  sprims.AddIndexedTriangle(sources.indices, left[nlayers], right[nlayers], mid)
end

--
--
--

_Trapezoid_ = M.Trapezoid

return M