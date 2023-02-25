--- Kicking the tires on algorithms.

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

local curve = require("curve")
local numeric = require("numeric")

local vv = {}

local function AddXY (x, y)
  vv[#vv + 1] = x
  vv[#vv + 1] = y
end

local X1, X2, X3, X4, X5, X6, X7, X8 = -150, -125, -107.5, -90, 90, 107.5, 125, 150
local Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8 = -100,  -75, -67.5, -50, 50, 67.5,  75, 100

AddXY(X4, Y1) -- 1
AddXY(X5, Y1) -- 2
--[[
local p1 = { x = X5, y = Y2 }
local p2 = { x = X7, y = Y4 }
local t1 = { x = 0, y = 85 }
local t2 = { x = 85, y = 0 }

local N = 3

for i = 0, N do
  AddXY(curve.GetPosition("hermite", p1, p2, t1, t2, i / N))
end
]]

AddXY(.825 * (X5 + X8) / 2, .775 * (Y1 + Y4) / 2)

AddXY(X8, Y4) -- 6

AddXY(X8, Y5) -- 7
--AddXY(X7, Y5) -- 8

--AddXY(X6, Y6) -- 9

AddXY(.825 * (X5 + X8) / 2, .775 * (Y5 + Y8) / 2)

--AddXY(X5, Y7) -- 10
AddXY(X5, Y8) -- 11
AddXY(X4, Y8) -- 12
--AddXY(X4, Y7) -- 13

--AddXY(X3, Y6) -- 14
if false then
AddXY(.825 * (X1 + X4) / 2, .775 * (Y5 + Y8) / 2)

AddXY(X2, Y5) -- 15
AddXY(X1, Y5) -- 16
AddXY(X1, Y4) -- 17
AddXY(X2, Y4) -- 18

--AddXY(X3, Y3) -- 19
AddXY(.825 * (X1 + X4) / 2, .775 * (Y1 + Y4) / 2)
end
--AddXY(X4, Y2) -- 20

AddXY(0, 0) -- 21

local CP = #vv / 2

local ii = {}

for i = 1, CP - 1 do
  ii[#ii + 1] = i

  if i + 1 < CP then
    ii[#ii + 1] = i + 1
  else
    ii[#ii + 1] = 1
  end

  ii[#ii + 1] = CP
end
---[[
do
  local m = display.newMesh{
    x = display.contentCenterX,
    y = display.contentCenterY,
    vertices = vv, indices = ii,
    mode = "indexed"
  }

  for i = 1, CP do
    m:setFillVertexColor(i, math.random(), 0, math.random())
  end

  m:scale(64 / (X8 - X1), 64 / (Y8 - Y1))
end
--]]

--do return end
local function AddIndexedTri (is, i1, i2, i3)
  is[#is + 1] = i1
  is[#is + 1] = i2
  is[#is + 1] = i3
end

local x1, y1 = display.contentCenterX, display.contentCenterY
local x2, y2 = x1 - 200, y1 - 200
local x3, y3 = x1 + 200, y1 - 200

local vlist = {}

local function Add (vl, x, y)
  vl[#vl + 1] = x
  vl[#vl + 1] = y
if not AA then
display.newCircle(x, 100 + y, 5):setFillColor(0, 0, 1)
end
  return #vl / 2
end

local function AddLerped (vl, x1, y1, x2, y2, t)
  local s = 1 - t

  return Add(vl, s * x1 + t * x2, s * y1 + t * y2)
end

local Middle = Add(vlist, x1, y1)

local Left, Right = {}, {}

local UUVV={}
AA=true
Add(UUVV,.5,0)
AA=false
local NN = 5--7

for i = 1, NN - 1 do
  local t = (i - 1) / (NN - 1)

if true then
  Left[i] = AddLerped(vlist, x2, y2, x2, y1, t)
  Right[i] = AddLerped(vlist, x3, y3, x3, y1, t)
else
  Left[i] = AddLerped(vlist, x2, y2, x1, y1, t)
  Right[i] = AddLerped(vlist, x3, y3, x1, y1, t)
end
AA=true
if true then
  AddLerped(UUVV, 0, 0, 1, 0, t)
  AddLerped(UUVV, 0, 0, 1, 0, t)
else
  AddLerped(UUVV, 0, 0, .5, 0, t)
  AddLerped(UUVV, 1, 0, .5, 0, t)
end
AA=false
end

local PrevRow, CurRow = {}, {}

local function DoRectangle (left, right, cols, vs, is)
  local n = #left

  assert(n == #right, "Unbalanced rectangle edges")

  for i = 1, n do
    local li, ri = left[i] * 2, right[i] * 2
    local lx, ly = vs[li - 1], vs[li]
    local rx, ry = vs[ri - 1], vs[ri]
local lu, ru = UUVV[li - 1], UUVV[ri - 1]
    CurRow[1] = left[i]

    for j = 1, cols do
      CurRow[j + 1] = AddLerped(vs, lx, ly, rx, ry, j / cols)
AA=true
print("L,LL",lu,1 - 4*(lu - .5)^2)
print("R,RR",ru,1 - 4*(ru - .5)^2)
AddLerped(UUVV, lu, 1 - 4*(lu - .5)^2, ru, 1 - 4*(ru - .5)^2, j / cols)
AA=false
    end

    if i > 1 then
      for j = 1, cols do
        AddIndexedTri(is, PrevRow[j], PrevRow[j + 1], CurRow[j])
        AddIndexedTri(is, CurRow[j], PrevRow[j + 1], CurRow[j + 1])
      end
    end

    CurRow, PrevRow = PrevRow, CurRow
  end
end

local function DoTrapezoid (left, right, n, vs, is)
  for i = 1, n do
    local li, ri = left[i] * 2, right[i] * 2
    local lx, ly = vs[li - 1], vs[li]
    local rx, ry = vs[ri - 1], vs[ri]
    local w = n - i + 1
local lu, ru = UUVV[li - 1], UUVV[ri - 1]
    CurRow[1] = left[i]

    for j = 1, w - 1 do
      CurRow[j + 1] = AddLerped(vs, lx, ly, rx, ry, j / w)
AA=true
AddLerped(UUVV, lu, 0, ru, 0, j / w)
AA=false
    end

    if i > 1 then
      for j = 1, w do
        AddIndexedTri(is, PrevRow[j], PrevRow[j + 1], CurRow[j])
      end
      
      for j = 1, w - 1 do
        AddIndexedTri(is, CurRow[j], PrevRow[j + 1], CurRow[j + 1])
      end

      AddIndexedTri(is, PrevRow[w + 1], right[i - 1], right[i])
      AddIndexedTri(is, CurRow[w], PrevRow[w + 1], right[i])
    end

    CurRow, PrevRow = PrevRow, CurRow
  end
end

local function DoTriangle (left, right, top, vs, is)
  local n = #left

  assert(n == #right, "Unbalanced triangle sides")

  DoTrapezoid(left, right, n, vs, is)

  AddIndexedTri(is, left[n], right[n], top)
end

local ilist = {}


DoRectangle(Left, Right, 10, vlist, ilist)
--DoTriangle(Left, Right, Middle, vlist, ilist)
--DoTrapezoid(Left, Right, 4, vlist, ilist)

local UVs = {}

local Frac = 1
local Inv = .925 / Frac

if UVs then
  for i = 1, #vlist, 2 do
    UVs[i] = UUVV[i]
  end

  for i = 2, #vlist, 2 do
    --UVs[i] = ((vlist[i - 1] + vlist[i]) % 1) * .675
    UVs[i] = (numeric.SampleNoise(vlist[i - 1], vlist[i] * 3.1) % 1) * .725 + UUVV[i] * .0625
  end
end

local m = display.newMesh{
  x = display.contentCenterX,
  y = display.contentCenterY,
  vertices = vlist, uvs = UVs, indices = ilist,
  mode = "indexed"
}

m:toBack()

if UVs then
  m.fill.effect = require("wood")
else
  for i = 1, #vlist / 2 do
    m:setFillVertexColor(i, math.random(), 0, math.random())
  end
end
m:scale(1,.25)
local convert = require("convert")
local bezier3 = require("bezier3")
local sampling = require("sampling")

local b1, b2, b3, b4 = {}, {}, {}, {}

for j = 1, 3 do
  local p1 = { x = 50, y = 100 + (j - 1) * 35 }
  local p2 = { x = 150, y = 200 + (j - 1) * 35 }
  local t1 = { x = 0, y = 125 + (j - 1) * 55 }
  local t2 = { x = 125 + (j - 1) * 55, y = 0 }

  local N = 11

  local set, result = sampling.New(), {}

  convert.HermiteToBezier(p1, p2, t1, t2, b1, b2, b3, b4)
  bezier3.PopulateArcLengthLUT(set, b1, b2, b3, b4)

  for i = 0, N do
    set:Lookup_01(result, i / N)

    local t = result.y1 + result.frac * (result.y2 - result.y1)
    local x, y = curve.GetPosition("hermite", p1, p2, t1, t2, t)

    display.newCircle(x, y, 5):setFillColor(math.random(), math.random(), math.random())
  end
end

for j = 1, 7 do
  local p1 = { x = 650 - (j - 1) * 35, y = 5 }
  local p2 = { x = 750, y = 105 + (j - 1) * 35 }
  local t1 = { x = 0, y = 225 + (j - 1) * 55 }
  local t2 = { x = 225 + (j - 1) * 55, y = 0 }

  local N = 11

  local set, result = sampling.New(), {}

  convert.HermiteToBezier(p1, p2, t1, t2, b1, b2, b3, b4)
  bezier3.PopulateArcLengthLUT(set, b1, b2, b3, b4)

  for i = 0, N do
    set:Lookup_01(result, i / N)

    local t = result.y1 + result.frac * (result.y2 - result.y1)
    local x, y = curve.GetPosition("hermite", p1, p2, t1, t2, t)

    display.newCircle(x, y, 5):setFillColor(math.random(), math.random(), math.random())
  end
end