--- Utilties for some second-order shapes, etc.

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
local remove = table.remove

-- Modules --
local curve = require("curve")
local sflags = require("shape_flags")
local shapes = require("shapes")
local sprims = require("shape_prims")

-- Cached module references --
local _GetEdge_
local _GetProp_

-- Exports --
local M = {}

--
--
--

local P1, P2, T1, T2 = {}, {}, {}, {}

--
--
--

local Dirs = {
  up = { x = 0, y = -1 },
  left = { x = -1, y = 0 },
  right = { x = 1, y = 0 },
  down = { x = 0, y = 1 }
}

local function GetDir (what, scale)
  local dir = Dirs[what]

  return dir.x * scale, dir.y * scale
end

--
--
--

local Result = {}

local function ArcLengthTo (layer, t)
  _GetProp_("layers")[layer]:Lookup_01(Result, t)

  return Result.y1 + Result.frac * (Result.y2 - Result.y1)
end

--
--
--

local DT1, DT2, CurLayer

local function Curve (sources, lx, ly, rx, ry, t, layer)
  if layer ~= CurLayer then
    local scale = _GetProp_("outer_tangent") - (layer - 1) * _GetProp_("tangent_step")

    T1.x, T1.y = GetDir(DT1, scale)
    T2.x, T2.y = GetDir(DT2, scale)
    CurLayer = layer
  end

  P1.x, P1.y = lx, ly
  P2.x, P2.y = rx, ry

  --
  --
  --

  local s, nfunc = ArcLengthTo(layer, t), sources.normals_func

  if nfunc then
    local tx, ty = curve.GetTangent("hermite", P1, P2, T1, T2, s)

    nfunc("arc", ty, -tx, layer - 1, _GetProp_("layer_count"))
  end

  return sprims.AddPair(sources.vertices, curve.GetPosition("hermite", P1, P2, T1, T2, s))
end

--
--
--

function M.CornerCurve (sources, ledge, redge, dir1, dir2)
  DT1, DT2 = dir1, dir2

  shapes.Trapezoid(sources, ledge, redge, _GetProp_("outside_curve_count"), Curve)
end

--
--
--

local function AddPoint (sources, x, y, u, v)
  local index = sprims.AddPair(sources.vertices, x, y)

  sprims.AddPair(sources.uvs, u, v)

  return index, x, y
end

--
--
--

function M.CornerTriangles (sources, ledge, redge, mid, nx, ny)
  local layer_count = _GetProp_("layer_count")

  assert(layer_count and layer_count % 2 == 0)

  local x1, y1, u1 = sprims.GetPoint(sources, ledge[2])
  local x2, y2, u2 = sprims.GetPoint(sources, redge[2])
  local top = AddPoint(sources, (x1 + x2) / 2, (y1 + y2) / 2, (u1 + u2) / 2, 1)

  if sources.normals_func then
    sources.normals_func("top", nx, ny, 0, 1)
  end

  -- Beyond a certain point the triangles become slivers and the u-value interpolation
  -- suffers, so break off the latter part of each edge.
  local is, corner_count, l2, r2 = sources.indices, _GetProp_("corner_count"), {}, {}

  for i = corner_count + 1, #ledge do
    l2[#l2 + 1], ledge[i] = ledge[i]
    r2[#r2 + 1], redge[i] = redge[i]
  end

  -- Add a two-triangle "dip" to approximate the corner curve, and forget the first row.
  sprims.AddIndexedTriangle(is, ledge[1], ledge[2], top)
  sprims.AddIndexedTriangle(is, redge[1], redge[2], top)

  remove(ledge, 1)
  remove(redge, 1)

  -- Begin the interior as a two-wide rectangle.
  sprims.SetEdgeNormal(nx, ny)
  shapes.SetPrevRow{ ledge[1], top, redge[1] }

  shapes.Rectangle(sources, ledge, redge, 2)

  -- Use three triangles to populate the next row, and build on that to fill the remainder
  -- with a one-wide rectangle. Close with a triangle.
  local i2 = shapes.GetFromPreviousRow(2)

  sprims.AddIndexedTriangle(is, ledge[#ledge], i2, l2[1])
  sprims.AddIndexedTriangle(is, redge[#redge], i2, r2[1])
  sprims.AddIndexedTriangle(is, l2[1], i2, r2[1])
  shapes.Rectangle(sources, l2, r2, 1, corner_count) -- n.b. adjusted row; also no new points, so shorthand for indexed triangle calls
  sprims.AddIndexedTriangle(is, l2[#l2], r2[#r2], mid)
end

--
--
--

local function AuxGetEdge (what, reverse)
  local offset = _GetProp_("offset")

  if what == "top" or what == "bottom" then
    local x1, x2, u1, u2, nx = _GetProp_("x1") + offset, _GetProp_("x2") - offset, 1, 0, -1
    
    if reverse then
      x1, x2, u1, u2, nx = x2, x1, u2, u1, 1
    end

    local y = _GetProp_(what == "top" and "y1" or "y2")

    return x1, y, u1, x2, y, u2, nx, 0
  else
    local y1, y2, u1, u2, ny = _GetProp_("y1") + offset, _GetProp_("y2") - offset, 0, 1, -1

    if reverse then
      y1, y2, u1, u2, ny = y2, y1, u2, u1, 1
    end
    
    local x = _GetProp_(what == "left" and "x1" or "x2")

    return x, y1, u1, x, y2, u2, 0, ny
  end
end

--
--
--

function M.GetEdge (sources, edge, what, how)
  local wants_to_reverse = how == "reverse"

  if not edge then
    local layer_count = _GetProp_("layer_count")
    local nfunc, x1, y1, u1, x2, y2, u2, nx, ny = sources.normals_func, AuxGetEdge(what, wants_to_reverse)

    for i = 1, nfunc and layer_count + 1 or 0 do
      nfunc("arc", nx, ny, i - 1, layer_count)
    end

    edge = sprims.Edge(sources, x1, y1, u1, x2, y2, u2, layer_count)
    edge.nx, edge.ny, edge.reverse = nx, ny, wants_to_reverse
  elseif not edge.reverse ~= not wants_to_reverse then
    sprims.ReverseEdge(edge)

    edge.nx, edge.ny, edge.reverse = -edge.nx, -edge.ny
  end

  return edge
end

--
--
--

function M.GetMiddle (sources)
  if sources.normals_func then
    sources.normals_func("middle", 0, 0, 0, 1)
  end

  return AddPoint(sources, (_GetProp_("x1") + _GetProp_("x2")) / 2, (_GetProp_("y1") + _GetProp_("y2")) / 2, .5, 0)
end

--
--
--

local Props = {}

--
--
--

function M.GetProp (name)
  return Props[name]
end

--
--
--

function M.NubOnEdge (sources, edge, dir1, dir2)
  DT1, DT2 = dir1, dir2

  sprims.SetEdgeNormal(GetDir(dir1, 1))
  shapes.Nub(sources, edge, #edge - 1, _GetProp_("outside_nub_count"), Curve)
end

--
--
--

function M.SetProp (name, value)
  Props[name] = assert(value)
end

--
--
--

local OmitBoth = sflags.DummyFirst + sflags.OmitLast
local OmitAndDoNormals = OmitBoth + sflags.DoNormals

--
--
--

function M.TriangleTowardMiddle (sources, top, what, mid, mx, my, how)
  top = _GetEdge_(sources, top, what, how)

  local n = #top
  local x1, y1, u1 = sprims.GetPoint(sources, top[1])
  local x2, y2, u2 = sprims.GetPoint(sources, top[n])
  
  sprims.SetEdgeNormal(-top.nx, -top.ny)

  local redge = sprims.Edge(sources, x2, y2, u2, mx, my, .5, #top - 1, OmitAndDoNormals)
  
  sprims.SetEdgeNormal(top.nx, top.ny) -- n.b. left in place for triangle
  
  local ledge = sprims.Edge(sources, x1, y1, u1, mx, my, .5, #top - 1, OmitAndDoNormals)

  ledge[1] = top[1]
  redge[1] = top[n]

  shapes.SetPrevRow(top)
  shapes.Triangle(sources, ledge, redge, mid, sflags.DoInterior)

  return ledge, redge, top
end

--
--
--

_GetEdge_ = M.GetEdge
_GetProp_ = M.GetProp

return M