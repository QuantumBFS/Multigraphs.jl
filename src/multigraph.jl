using SparseArrays, LinearAlgebra

import LightGraphs: ne, is_directed, add_edge!, rem_edge!,
        degree, indegree, outdegree

export Multigraph

"""
    Multigraph{T,U} <: AbstractMultigraph{T,U}

A struct for undirected multigraph with index type `T`
and the multiplicity type `U`.
"""
mutable struct Multigraph{T<:Integer, U<:Integer} <: AbstractMultigraph{T, U}
    adjmx::SparseMatrixCSC{U, T}
    function Multigraph{T, U}(adjmx::SparseMatrixCSC{U, T}) where {T<:Integer, U<:Integer}
        m, n = size(adjmx)
        if m != n
            error("Adjacency matrices should be square!")
        end
        if !issymmetric(adjmx)
            error("Adjacency matrices should be symmetric!")
        end
        if nnz(adjmx .!= 0) != nnz(adjmx .> 0)
            error("All elements in adjacency matrices should be non-negative!")
        end
        new{T, U}(dropzeros(adjmx))
    end
end

"""
    Multigraph(adjmx::SparseMatrixCSC{U, T})

Construct a `Multigraph{T,U}` whose adjacency matrix is `adjmx`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs, SparseArrays

julia> Multigraph(spzeros(Int, 3, 3))
{3, 0} undirected $(Int) multigraph with $(Int) multiplicities
```
"""
Multigraph(adjmx::SparseMatrixCSC{U, T}) where {U<:Integer, T<:Integer} = Multigraph{T, U}(adjmx)

"""
    Multigraph(m::AbstractMatrix{U})

Construct a `Multigraph{Int,U}` whose adjacency matrix is `m`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> Multigraph(zeros(Int, 4, 4))
{4, 0} undirected $(Int) multigraph with $(Int) multiplicities
```
"""
Multigraph(m::AbstractMatrix{U}) where {U<:Integer} = Multigraph{Int, U}(SparseMatrixCSC{U, Int}(m))

"""
    Multigraph(n::T) where {T<:Integer}

Construct a `Multigraph{T,Int}` with `n` vertices and 0 multiple edges.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> Multigraph(5)
{5, 0} undirected $(Int) multigraph with $(Int) multiplicities
```
"""
Multigraph(n::T) where {T<:Integer} = Multigraph(spzeros(Int, n, n))

"""
    Multigraph(g::SimpleGraph)

Convert a `SimpleGraph{T}` to a `Multigraph{T,Int}`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> Multigraph(path_graph(5))
{5, 4} undirected $(Int) multigraph with $(Int) multiplicities
```
"""
Multigraph(g::SimpleGraph) = Multigraph(adjacency_matrix(g))

"""
    ne(g::AbstractMultigraph, count_mul::Bool = false)

Return the number of (multiple / simple) edges in `g`
if `count_mul = (false / true)`.

## Examples
```jldoctest
julia> using LightGraphs, Multigraphs

julia> g = Multigraph([0 2 1; 2 0 0; 1 0 0])
{3, 2} undirected $(Int) multigraph with $(Int) multiplicities

julia> ne(g), ne(g, true)
(2, 3)
```
"""
ne(g::Multigraph, count_mul::Bool = false) = (count_mul ? sum(g.adjmx) ÷ 2 : ((nnz(g.adjmx) + nnz(diag(g.adjmx))) ÷ 2))

is_directed(g::Multigraph{T, U}) where {T<:Integer, U<:Integer} = false

function add_edge!(g::Multigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    if src(e) in vertices(g) && dst(e) in vertices(g)
        g.adjmx[src(e), dst(e)] += mul(e)
        g.adjmx[dst(e), src(e)] += mul(e)
        return true
    else
        return false
    end
end

function rem_edge!(g::Multigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    if has_edge(g, e)
        g.adjmx[src(e), dst(e)] -= mul(e)
        g.adjmx[dst(e), src(e)] -= mul(e)
        dropzeros!(g.adjmx)
        return true
    else
        return false
    end
end

# inneighbors(g::Multigraph, v) = outneighbors(g, v)
degree(g::Multigraph) = [(sum(g.adjmx[:,v]) - g.adjmx[v,v] ÷ 2) for v in 1:nv(g)]
indegree(g::Multigraph) = degree(g)
outdegree(g::Multigraph) = degree(g)
degree(g::Multigraph{T,U}, v::T) where {T<:Integer, U<:Integer} = degree(g)[v]
indegree(g::Multigraph{T,U}, v::T) where {T<:Integer, U<:Integer} = indegree(g)[v]
outdegree(g::Multigraph{T,U}, v::T) where {T<:Integer, U<:Integer} = outdegree(g)[v]
