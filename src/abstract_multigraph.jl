using LightGraphs
using SparseArrays

import Base: show, eltype, copy
import LightGraphs: nv, has_edge, has_vertex, edgetype, add_edge!, rem_edge!, rem_vertex!,
    rem_vertices!, add_vertex!, add_vertices!, outneighbors, inneighbors, vertices, edges,
    adjacency_matrix

export AbstractMultigraph
export multype

"""
    AbstractMultigraph{T, U}<:AbstractGraph{T}

An abstract type representing a multigraph.
"""
abstract type AbstractMultigraph{T<:Integer, U<:Integer} <:AbstractGraph{T} end

function copy(g::AbstractMultigraph{T, U}) where {T, U}
    new_g = is_directed(g) ? DiMultigraph(copy(g.adjmx)) : Multigraph(copy(g.adjmx))
    return new_g
end

function show(io::IO, g::AbstractMultigraph{T, U}) where {T,U}
    dir = is_directed(g) ? "directed" : "undirected"
    print(io, "{$(nv(g)), $(ne(g))} $(dir) $(T) multigraph with $(U) multiplicities")
end

eltype(g::AbstractMultigraph{T, U}) where {T<:Integer, U<:Integer} = T
multype(g::AbstractMultigraph{T, U}) where {T<:Integer, U<:Integer} = U
edgetype(g::AbstractMultigraph) = MultipleEdge{eltype(g), multype(g)}

nv(g::AbstractMultigraph) = size(g.adjmx, 1)
vertices(g::AbstractMultigraph{T, U}) where {T<:Integer, U<:Integer} = one(T):nv(g)

adjacency_matrix(g::AbstractMultigraph) = g.adjmx

function has_edge(g::AbstractMultigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    if src(e) <= nv(g) && dst(e) <= nv(g)
        return g.adjmx[src(e), dst(e)] >= mul(e)
    else
        return false
    end
end

has_edge(g::AbstractMultigraph{T, U}, t) where {T<:Integer, U<:Integer} = has_edge(g, MultipleEdge(t))
add_edge!(g::AbstractMultigraph{T, U}, t) where {T<:Integer, U<:Integer} = add_edge!(g, MultipleEdge(t))
rem_edge!(g::AbstractMultigraph{T, U}, t) where {T<:Integer, U<:Integer} = rem_edge!(g, MultipleEdge(t))

has_edge(g::AbstractMultigraph{T, U}, x, y) where {T<:Integer, U<:Integer} = has_edge(g, MultipleEdge(x, y))
add_edge!(g::AbstractMultigraph{T, U}, x, y) where {T<:Integer, U<:Integer} = add_edge!(g, MultipleEdge(x, y))
rem_edge!(g::AbstractMultigraph{T, U}, x, y) where {T<:Integer, U<:Integer} = rem_edge!(g, MultipleEdge(x, y))

"""
    has_edge(g::AbstractMultigraph, s, d, mul)

Return `true` if `g` has a multiple edge from `s` to `d` whose multiplicity
is not less than `mul`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> g = Multigraph(3);

julia> add_edge!(g, 1, 2, 2);

julia> has_edge(g, 1, 2, 3)
false

julia> has_edge(g, 1, 2, 2)
true
```
"""
has_edge(g::AbstractMultigraph{T, U}, x, y, z) where {T<:Integer, U<:Integer} = has_edge(g, MultipleEdge(x, y, z))

"""
    add_edge!(g::AbstractMultigraph, s, d, mul)

Add a multiple edge from `s` to `d` multiplicity `mul`. If there is a multiple
edge from `s` to `d`, it will increase its multiplicity by `mul`.

Return `true` multiple edge was added successfully, otherwise return `false`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> g = Multigraph(3);

julia> e = MultipleEdge(1, 2, 1);

julia> add_edge!(g, e);

julia> ne(g, true)
1

julia> add_edge!(g, e);

julia> ne(g, true)
2
```
"""
add_edge!(g::AbstractMultigraph{T, U}, x, y, z) where {T<:Integer, U<:Integer} = add_edge!(g, MultipleEdge(x, y, z))

"""
    rem_edge!(g::AbstractMultigraph, s, d, mul)

Remove the multiplicity of edge from `s` to `d` by `mul` in `g`, if `g` has such
a multiple edge.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> g = Multigraph(3);

julia> add_edge!(g, 1, 2, 2);

julia> rem_edge!(g, 1, 2, 3)
false

julia> rem_edge!(g, 1, 2, 2)
true
```
"""
rem_edge!(g::AbstractMultigraph{T, U}, x, y, z) where {T<:Integer, U<:Integer} = rem_edge!(g, MultipleEdge(x, y, z))

has_vertex(g::AbstractMultigraph, v::Integer) = v in vertices(g)
function rem_vertex!(g::AbstractMultigraph{T, U}, v::T) where {T<:Integer, U<:Integer}
    vsg = vertices(g)
    vmap = [u for u in vsg]
    if v in vsg
        g.adjmx = g.adjmx[vsg .!= v, vsg .!= v]
        deleteat!(vmap, v)
        dropzeros!(g.adjmx)
    end
    return vmap
end

function rem_vertices!(g::AbstractMultigraph{T, U}, vs::Vector{T}) where {T<:Integer, U<:Integer}
    vsg = vertices(g)
    vmap = [u for u in vsg]
    for v in sort(vs, rev = true)
        rem_vertex!(g, v)
        if v <= length(vmap)
            deleteat!(vmap, v)
        end
    end
    return vmap
end

function add_vertices!(g::AbstractMultigraph{T, U}, n::T) where {T<:Integer, U<:Integer}
    mat = g.adjmx
    mat = SparseMatrixCSC(mat.m+n, mat.n+n, [mat.colptr; [mat.colptr[end] for i = one(T):n]], mat.rowval, mat.nzval)
    g.adjmx = mat
    g
end

add_vertex!(g::AbstractMultigraph{T, U}) where {T<:Integer, U<:Integer} = add_vertices!(g, one(T))

function outneighbors(g::AbstractMultigraph, v::Integer)
    if v in vertices(g)
        mat = g.adjmx
        return mat[v, :].nzind
    end
end

function inneighbors(g::AbstractMultigraph, v::Integer)
    if v in vertices(g)
        mat = g.adjmx
        return mat[:, v].nzind
    end
end

"""
    edges(g::AbstractMultigraph)

Return a  `MultipleEdgeIter` for `g`.

## Examples
```jltestdoc
julia>
julia> using LightGraphs, Multigraphs

julia> g = Multigraph(path_graph(4));

julia> add_edge!(g, 1, 3, 2);

julia> collect(edges(g))
4-element Array{Any,1}:
 Multiple edge 1 => 2 with multiplicity 1
 Multiple edge 1 => 3 with multiplicity 2
 Multiple edge 2 => 3 with multiplicity 1
 Multiple edge 3 => 4 with multiplicity 1

```
"""
edges(g::AbstractMultigraph) = MultipleEdgeIter(g)
