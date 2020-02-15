using SparseArrays, LinearAlgebra

import LightGraphs: ne, is_directed, add_edge!, rem_edge!, inneighbors

export DiMultigraph

mutable struct DiMultigraph{T<:Integer, U<:Integer} <: AbstractMultigraph{T, U}
    adjmx::SparseMatrixCSC{U, T}
    function DiMultigraph{T, U}(adjmx::SparseMatrixCSC{U, T}) where {T<:Integer, U<:Integer}
        m, n = size(adjmx)
        if m != n
            error("Adjacency matrices should be square!")
        end
        if nnz(adjmx .!= 0) != nnz(adjmx .> 0)
            error("All elements in adjacency matrices should be non-negative!")
        end
        new{T, U}(dropzeros(adjmx))
    end
end

DiMultigraph(adjmx::SparseMatrixCSC{U, T}) where {U<:Integer, T<:Integer} = DiMultigraph{T, U}(adjmx)
DiMultigraph(m::AbstractMatrix{U}) where {U<:Integer} = DiMultigraph{Int, U}(SparseMatrixCSC{U, T}(m))
DiMultigraph(n::T) where {T<:Integer} = DiMultigraph(spzeros(Int, n, n))

# ne(g) for counting multiple edges, ne(g, true) for counting simple edges
ne(g::DiMultigraph, count_mul::Bool = false) = (count_mul ? sum(g.adjmx) : nnz(g.adjmx))

is_directed(g::DiMultigraph{T, U}) where {T<:Integer, U<:Integer} = true

function add_edge!(g::DiMultigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    g.adjmx[src(e), dst(e)] += mul(e)
    g
end

function rem_edge!(g::DiMultigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    if has_edge(g, e)
        g.adjmx[src(e), dst(e)] -= mul(e)
        dropzeros!(g.adjmx)
    else
        error("This directed multigraph has no {$(e)}!")
    end
    g
end

inneighbors(g::DiMultigraph{T, U}, v::T) where {T<:Integer, U<:Integer} = g.adjmx[v,:].nzind
