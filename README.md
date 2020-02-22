# Multigraphs

[![Build Status](https://travis-ci.com/ChenZhao44/Multigraphs.jl.svg?branch=master)](https://travis-ci.com/ChenZhao44/Multigraphs.jl)
[![Codecov](https://codecov.io/gh/ChenZhao44/Multigraphs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ChenZhao44/Multigraphs.jl)

Multigraphs extension for `LightGraphs.jl`.

Examples:
```
using LightGraphs, Multigraphs

julia> mg = Multigraph(3) # use DiMultigraph for directed multigraphs.
{3, 0} undirected Int64 multigraph with Int64 multiplicities

julia> add_edge!(mg, 1, 2, 2) # add a multiple edge from 1 to 2 with multiplicity 2
true

julia> add_edge!(mg, 2, 3) # add a simple edge (multiple edge with multiplicity 1) from 2 to 3
true

julia> add_edge!(mg, 2, 3, 2) # this will increase multiplicity of the edge from 2 to 3 by 2
true

julia> rem_edge!(mg, 2, 3, 2) # this will decrease multiplicity of the edge from 2 to 3 by 1

julia> mes = [me for me in edges(mg)] # me is a MultipleEdge
2-element Array{MultipleEdge{Int64,Int64},1}:
Multiple edge 1 => 2 with multiplicity 2
Multiple edge 2 => 3 with multiplicity 1

julia> for e in mes[1] # e is a LightGraphs.SimpleEdge
           println(e)
       end
Edge 1 => 2
Edge 1 => 2


```
