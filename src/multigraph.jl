using SparseArrays

import LightGraphs: ne, is_directed, add_edge!

export Multigraph

mutable struct Multigraph{T<:Integer, U<:Integer} <: AbstractMultigraph{T, U}
    adjmx::SparseMatrixCSC{U, T}
    function Multigraph{T, U}(adjmx::SparseMatrixCSC{U, T}) where {T<:Integer, U<:Integer}
        new{T, U}(dropzeros(adjmx))
    end
end

Multigraph(adjmx::SparseMatrixCSC{U, T}) where {U<:Integer, T<:Integer} = Multigraph{T, U}(adjmx)
Multigraph(m::AbstractMatrix{U}) where {U<:Integer} = Multigraph{Int, U}(SparseMatrixCSC{U, T}(m))
Multigraph(n::T) where {T<:Integer} = Multigraph(spzeros(Int, n, n))

# ne(g) for counting multiple edges, ne(g, true) for counting simple edges
ne(g::Multigraph, count_mul::Bool = false) = (count_mul ? sum(g.adjmx) ÷ 2 : nnz(g.adjmx) ÷ 2)

is_directed(g::Multigraph{T, U}) where {T<:Integer, U<:Integer} = false

function add_edge!(g::Multigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    g.adjmx[src(e), dst(e)] += mul(e)
    g.adjmx[dst(e), src(e)] += mul(e)
    g
end

function rem_edge!(g::Multigraph{T, U}, e::AbstractMultipleEdge{T, U}) where {T<:Integer, U<:Integer}
    if has_edge(g, e)
        g.adjmx[src(e), dst(e)] -= mul(e)
        g.adjmx[dst(e), src(e)] -= mul(e)
    else
        error("This multigraph has no {$(e)}!")
    end
    g
end
