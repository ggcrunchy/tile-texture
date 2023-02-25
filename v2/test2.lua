--- Trying to put the stuff from test1 into production.

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

local TileTypes = {
  UpperLeft = { abbr = "UL", dirs = { "right", "down" } },
  UpperRight = { abbr = "UR", dirs = { "left", "down" } },
  LowerLeft = { abbr = "LL", dirs = { "right", "up" } },
  LowerRight = { abbr = "LR", dirs = { "left", "up" } },
  LeftNub = { abbr = "_L", dirs = { "right" } },
  RightNub = { abbr = "_R", dirs = { "left" } },
  TopNub = { abbr = "_T", dirs = { "down" } },
  BottomNub = { abbr = "_B", dirs = { "up" } },
  Horizontal = { abbr = "_H", dirs = { "left", "right" } },
  Vertical = { abbr = "_V", dirs = { "down", "up" } },
  TopT = { abbr = "TT", dirs = { "left", "right", "down" } },
  BottomT = { abbr = "BT", dirs = { "left", "right", "up" } },
  LeftT = { abbr = "LT", dirs = { "right", "up", "down" } },
  RightT = { abbr = "RT", dirs = { "left", "up", "down" } },
  FourWays = { abbr = "_4", dirs = { "left", "right", "up", "down" } }
}

--
--
--

local TestLevel = {
---[[
  "UL", "_H", "TT", "UR", "_L", "_H", "_H", "EOL",
  "_V", "_T", "_B", "_V", "__", "__", "__",
  "LL", "RT", "__", "_V", "__", "__", "__",
  "__", "_4", "_R", "_V", "__", "__", "__",
  "__", "LT", "BT", "LR", "__", "__", "__"
--]]
--[[
  "_H","RT","EOL"
--]]
}

--
--
--

local Cols, Rows

for i, v in ipairs(TestLevel) do
  if v == "EOL" then
    Cols = i - 1
    
    table.remove(TestLevel, i)
    
    assert(#TestLevel % Cols == 0, "Bad number of columns in some row")
    
    Rows = #TestLevel / Cols
    
    break
  end
end

local function pprint () end
-- pprint = print

pprint(("Rows = %i, Columns = %i"):format(Rows, Cols))
pprint("")

--
--
--

local Components = {}

do
  local index, visited = 1, {}

  for i, v in ipairs(TestLevel) do
    if v == "__" then
      visited[i] = true
    end
  end

  local function AddCell (comp, index, row, col)
    visited[index] = true

    local what = TestLevel[index]

    for k, v in pairs(TileTypes) do
      if v.abbr == what then
        comp[#comp + 1] = { col = col, row = row, what = k }

        for _, dir in ipairs(v.dirs) do
          if dir == "up" and row > 1 and not visited[index - Cols] then
            AddCell(comp, index - Cols, row - 1, col)
          elseif dir == "left" and col > 1 and not visited[index - 1] then
            AddCell(comp, index - 1, row, col - 1)
          elseif dir == "right" and col < Cols and not visited[index + 1] then
            AddCell(comp, index + 1, row, col + 1)
          elseif dir == "down" and row < Rows and not visited[index + Cols] then
            AddCell(comp, index + Cols, row + 1, col)
          end
        end

        break
      end
    end
  end

  for row = 1, Rows do
    for col = 1, Cols do
      if not visited[index] then
        local comp = {}

        AddCell(comp, index, row, col)
      
        Components[#Components + 1] = comp
      end

      index = index + 1
    end
  end
end

--
--
--

for i, v in ipairs(Components) do
  pprint(("Connected component #%i, raw..."):format(i))
  pprint("")
  
  local sorted = {}
  
  for _, cell in pairs(v) do
    pprint(("(row = %i, col = %i): %s"):format(cell.row, cell.col, cell.what))
    
    cell.index = (cell.row - 1) * Cols + cell.col
    
    sorted[#sorted + 1] = cell
  end
  
  table.sort(sorted, function(a, b)
    return a.index < b.index
  end)

  pprint("")
  pprint("...and sorted" .. (i == 1 and " (top to bottom, then left to right)" or "") .. ":")
  pprint("")

  for _, cell in ipairs(sorted) do
    pprint(("(row = %i, col = %i): %s"):format(cell.row, cell.col, cell.what))
  end

  Components[i] = sorted

  pprint("")
end

--
--
--

display.setDefault("background", .45)

--
--
--

local builders = require("builders")
local sutils = require("shape_utils")

sutils.SetProp("corner_count", 7)
sutils.SetProp("layer_count", 10)
sutils.SetProp("inside_curve_count", 6)
sutils.SetProp("rectangle_count", 10)
sutils.SetProp("outside_nub_count", 18)

--
--
--

local width, height = 64, 64

sutils.SetProp("offset", 8)
sutils.SetProp("tangent", 15)
sutils.SetProp("tangent_step", 16)

local ceil = math.ceil
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt

local LUTs = {}

local function GetLUT (n)
  local lut = LUTs[n]

  if not lut then
    lut = { 1 }

    local frac = pi / (2 * n)

    for i = 1, n - 1 do
      lut[i + 1] = cos(i * frac)
    end
    
    lut[n + 1], LUTs[n] = 0, lut
  end

  return lut
end

local Ignored = { middle = true, interior = true }

local function Lookup (what, i, n)
  local is_arc = what == "arc"
  local lut, flip = GetLUT(is_arc and ceil(n / 2) or n)

  n = #lut

  if what == "backward" then
    i = n - i + 1
  elseif is_arc and i > n then
    i, flip = 2 * n - i, true
  end

  local scale = lut[i]

  return flip and -scale or scale
end

local function BuildComponent (comp)
  local normals = {}

  local function Normals (what, x, y, i, n, ni)
    if what == "interior" then
      local index = ni * 2
      local scale = Lookup("arc", x, y) * Lookup("forward", i + 1, n)

      x, y = scale * normals[index - 1], scale * normals[index]
    elseif not Ignored[what] then
      local sq_len, numer = x^2 + y^2, 1

      if 1 + sq_len ~= 1 then
        if what ~= "top" then
          numer = Lookup(what, i + 1, n)
        end

        local scale = numer / sqrt(sq_len)

        x, y = x * scale, y * scale
      end
    end

    normals[#normals + 1] = x
    normals[#normals + 1] = y
  end

  local sources = { indices = {}, normals_func = Normals, vertices = {}, uvs = {} }
  local cur, y, tops, left = 1, 100, {}

  for row = 1, Rows do
    local x = 100

    for col = 1, Cols do
      local entry, what = comp[cur]
      
      if entry.col == col and entry.row == row then
        what, cur = entry.what, cur + 1
      end

      sutils.SetProp("x1", x)
      sutils.SetProp("y1", y)
      sutils.SetProp("x2", x + width - 1)
      sutils.SetProp("y2", y + height - 1)

      tops[col], left = builders.Call(what, sources, tops[col], left)

      if cur > #comp then
        return sources, normals
      else
        x = x + width
      end
    end

    y, left = y + height
  end

  return sources, normals
end

--
--
--

local effect = require("metal")
local numeric = require("numeric")

for _, comp in ipairs(Components) do
  local sources, normals = BuildComponent(comp)

  if effect.modify then
    effect.modify(sources--[[, level-specific...]])
  end
--normals=nil
  local vs, uvs = sources.vertices, sources.uvs

  for i = 2, #vs, 2 do
    local vnoise = numeric.SampleNoise(vs[i - 1], vs[i] * 3.1)

    uvs[i] = (vnoise % 1) * .725 + uvs[i] * .1625
  end

  for i = 1, #(normals or "") do--, 2 do
    uvs[i] = normals[i]
  --  uvs[i+1]=normals[i+1]+uvs[i+1]*.0525
  end

  local mesh = display.newMesh{ mode = "indexed", indices = sources.indices, vertices = vs, uvs = uvs }

  mesh:translate(mesh.path:getVertexOffset())

  mesh.fill.effect = effect.name
  --mesh:scale(2, 2)
end

--display.setDrawMode("wireframe", true)