Tile texture generator
======================

This is a tool for generating a 4x4 tileset (one cell going unused), with each tile being able to connect to one or more
of its neighbors: to the left or right, above, or below. What this amounts to is two straight segments (horizontal and
vertical), four nubs (facing in each cardinal direction), four corners, four three-way junctions, and one four-way
junction. Considerable effort has gone into making these mix-and-match, although I might be running up against some
topological limits (I would actually love to know). Positions, normals, knots, and indices are generated and may in
turn be used to produce a mesh and finally render that to a texture.

Some discussion may be found [here](https://www.youtube.com/watch?v=UKlaECIYRUA).

There is quite a lot of customization possible&mdash;perturbing the vertices and / or normals, say, or choosing the
shader that will consume the data&mdash;some of which is explored in that video.

---

There are some (probably unenlightening) drawings to go along with this and lay out how all the values line up.

The "triangles" (with two curved sides each) can get quite narrow and lead to "sliver"-type polygons. I have thought about
trying to mitigate this by making "valleys" where two cylinders come together now, but this might only move the difficulties
to the straight segments and literally involve going "back to the drawing board".

I have recently been experimenting with using the knots but the jury is still out on how practical these are on their own.
