using LightGraphs
using SparseArrays

import Base: show, eltype
import LightGraphs: nv, has_edge, edgetype, add_edge!, rem_edge!, rem_vertex!,
    rem_vertices!, add_vertex!, add_vertices!, outneighbors, vertices, edges

export AbstractMultigraph
export multype

abstract type AbstractMultigraph{T<:Integer, U<:Integer} <:AbstractGraph{T} end

function show(io::IO, g::AbstractMultigraph{T, U}) where {T,U}
    dir = is_directed(g) ? "directed" : "undirected"
    print(io, "{$(nv(g)), $(ne(g))} $(dir) $(T) multigraph with $(U) multiplicities")
end

eltype(g::AbstractMultigraph{T, U}) where {T<:Integer, U<:Integer} = T
multype(g::AbstractMultigraph{T, U}) where {T<:Integer, U<:Integer} = U
edgetype(g::AbstractMultigraph) = MultipleEdge{eltype(g), multype(g)}

nv(g::AbstractMultigraph) = size(g.adjmx, 1)
vertices(g::AbstractMultigraph{T, U}) where {T<:Integer, U<:Integer} = one(T):nv(g)

has_edge(g::AbstractMultigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer} = (g.adjmx[src(e), dst(e)] >= mul(e))

has_edge(g::AbstractMultigraph{T, U}, t) where {T<:Integer, U<:Integer} = has_edge(g, MultipleEdge(x))
add_edge!(g::AbstractMultigraph{T, U}, t) where {T<:Integer, U<:Integer} = add_edge!(g, MultipleEdge(x))
rem_edge!(g::AbstractMultigraph{T, U}, t) where {T<:Integer, U<:Integer} = rem_edge!(g, MultipleEdge(x))

has_edge(g::AbstractMultigraph{T, U}, x, y) where {T<:Integer, U<:Integer} = has_edge(g, MultipleEdge(x, y))
add_edge!(g::AbstractMultigraph{T, U}, x, y) where {T<:Integer, U<:Integer} = add_edge!(g, MultipleEdge(x, y))
rem_edge!(g::AbstractMultigraph{T, U}, x, y) where {T<:Integer, U<:Integer} = rem_edge!(g, MultipleEdge(x, y))

has_edge(g::AbstractMultigraph{T, U}, x, y, z) where {T<:Integer, U<:Integer} = has_edge(g, MultipleEdge(x, y, z))
add_edge!(g::AbstractMultigraph{T, U}, x, y, z) where {T<:Integer, U<:Integer} = add_edge!(g, MultipleEdge(x, y, z))
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
        return mat.rowval[mat.colptr[v]:(mat.colptr[v+1]-1)]
    end
end

edges(g::AbstractMultigraph) = MultipleEdgeIter(g)
