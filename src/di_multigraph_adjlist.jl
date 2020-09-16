using LightGraphs, SparseArrays, LinearAlgebra

import Base: copy
import LightGraphs: nv, has_edge, add_edge!, rem_edge!, rem_vertex!,
    rem_vertices!, add_vertex!, add_vertices!, outneighbors, inneighbors, neighbors,
    vertices, adjacency_matrix, ne, is_directed, degree, indegree, outdegree, edges,
    has_vertex, all_neighbors

export DiMultigraph

mutable struct DiMultigraph{T<:Integer} <: AbstractMultigraph{T}
    adjlist::Dict{T, Vector{T}}
    _idmax::T
    function DiMultigraph{T}(d::Dict{T, Vector{T}}, _idmax::T) where {T<:Integer}
        adjlist = deepcopy(d)
        vs = keys(adjlist)
        for (v, l) in adjlist
            if l ⊆ vs
                sort!(l)
            else
                error("Some vertices connected to $v is not in the multigraph!")
            end
        end
        _idmax = maximum(vs)
        new{T}(adjlist, _idmax)
    end
end

DiMultigraph(adjlist::Dict{T, Vector{T}}) where {T<:Integer} = DiMultigraph{T}(adjlist, maximum(keys(adjlist)))
function DiMultigraph(adjmx::AbstractMatrix{U}) where {U<:Integer}
    m, n = size(adjmx)
    if m != n
        error("Adjacency matrices should be square!")
    end
    if sum(adjmx .!= 0) != sum(adjmx .> 0)
        error("All elements in adjacency matrices should be non-negative!")
    end
    adjlist = Dict(zip((1:m), [Int[] for _ = 1:m]))
    for v1 = 1:m
        for v2 = 1:m
            for i = 1:adjmx[v1, v2]
                push!(adjlist[v1], v2)
            end
        end
    end
    DiMultigraph{Int}(adjlist, m)
end
DiMultigraph(n::T) where {T<:Integer} = DiMultigraph(Dict(zip(T(1):n, [T[] for _ = 1:n])))
DiMultigraph(g::SimpleDiGraph{T}) where {T<:Integer} = DiMultigraph(Dict(zip(T(1):nv(g), LightGraphs.SimpleGraphs.fadj(g))))

copy(mg::DiMultigraph{T}) where {T} = DiMultigraph{T}(deepcopy(mg.adjlist), mg._idmax)

nv(mg::DiMultigraph{T}) where {T<:Integer} = T(length(mg.adjlist))
vertices(mg::DiMultigraph) = collect(keys(mg.adjlist))
has_vertex(mg::DiMultigraph, v::Integer) = haskey(mg.adjlist, v)

function adjacency_matrix(mg::DiMultigraph)
    adjmx = spzeros(Int, nv(mg), nv(mg))

    ids = sort!(vertices(mg))
    for id1 in ids
        v1 = searchsortedfirst(ids, id1)
        for id2 in mg.adjlist[id1]
            v2 = searchsortedfirst(ids, id2)
            @inbounds adjmx[v1, v2] += 1
        end
    end
    return adjmx
end

function add_edge!(mg::DiMultigraph, me::AbstractMultipleEdge)
    s = src(me)
    d = dst(me)
    m = mul(me)
    if has_vertex(mg, s) && has_vertex(mg, d)
        for i = 1:m
            insert!(mg.adjlist[s], searchsortedfirst(mg.adjlist[s], d), d)
        end
        return true
    end
    return false
end

function rem_edge!(mg::DiMultigraph, me::AbstractMultipleEdge)
    if has_edge(mg, me)
        s = src(me)
        d = dst(me)
        m = mul(me)
        for i = 1:m
            deleteat!(mg.adjlist[s], searchsortedfirst(mg.adjlist[s], d))
        end
        return true
    else
        return false
    end
end

function rem_vertices!(mg::DiMultigraph{T}, vs::Vector{T}) where {T<:Integer}
    if all(has_vertex(mg, v) for v in vs)
        for v in vs
            for u in neighbors(mg, v)
                l = mg.adjlist[u]
                deleteat!(l, searchsorted(l, v))
            end
            delete!(mg.adjlist, v)
        end
        if mg._idmax in vs
            mg._idmax = maximum(keys(mg.adjlist))
        end
        return true
    end
    return false
end

function add_vertices!(mg::DiMultigraph{T}, n::Integer) where {T<:Integer}
    idmax = mg._idmax
    mg._idmax += n
    new_ids = collect((idmax+1):(idmax+n))
    for i in new_ids
        mg.adjlist[i] = T[]
    end
    return new_ids
end

function outneighbors(mg::DiMultigraph, v::Integer; count_mul::Bool = false)
    has_vertex(mg, v) || error("Vertex not found!")
    if count_mul
        return copy(mg.adjlist[v])
    else
        return sort!(collect(Set(mg.adjlist[v])))
    end
end
function inneighbors(mg::DiMultigraph{T}, v::Integer; count_mul::Bool = false) where T
    has_vertex(mg, v) || error("Vertex not found!")
    
    innb = T[]
    for u in vertices(mg)
        mul_u_v = length(searchsorted(outneighbors(mg, u), v))
        if mul_u_v > 0
            if count_mul
                for i = 1:mul_u_v
                    push!(innb, u)
                end
            else
                push!(innb, u)
            end
        end
    end
    sort!(innb)
    return innb
end
neighbors(mg::DiMultigraph, v::Integer; count_mul::Bool = false) = outneighbors(mg, v, count_mul = count_mul)
all_neighbors(mg::DiMultigraph, v::Integer) = sort!(union(outneighbors(mg, v), inneighbors(mg, v)))

function mul(mg::DiMultigraph, s::Integer, d::Integer)
    (has_vertex(mg, s) && has_vertex(mg, d)) || error("Vertices not found!")
    return length(searchsorted(mg.adjlist[s], d))
end

is_directed(mg::DiMultigraph) = true
function ne(mg::DiMultigraph; count_mul::Bool = false)
    if count_mul
        return sum([length(mg.adjlist[v]) for v in vertices(mg)])
    else
        return sum([length(Set(mg.adjlist[v])) for v in vertices(mg)])
    end
end

function outdegree(mg::DiMultigraph{T}) where T
    degs = Dict{T, Int}()
    for v in vertices(mg)
        degs[v] = length(mg.adjlist[v])
    end
    return degs
end
function indegree(mg::DiMultigraph{T}) where T
    degs = Dict{T, Int}()
    for v in vertices(mg)
        degs[v] = 0
    end
    for v in vertices(mg)
        for u in mg.adjlist[v]
            degs[u] += 1
        end
    end
    return degs
end
degree(mg::DiMultigraph) = outdegree(mg)
degree(mg::DiMultigraph, v::Integer) = outdegree(mg, v)
indegree(mg::DiMultigraph, v::Integer) = length(inneighbors(mg, v; count_mul = true))
outdegree(mg::DiMultigraph, v::Integer) = length(outneighbors(mg, v; count_mul = true))
