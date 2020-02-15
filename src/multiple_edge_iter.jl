using LightGraphs

import Base: eltype, iterate

export MultipleEdgeIter

struct MultipleEdgeIter{G<:AbstractMultigraph} <:AbstractEdgeIter
    g::G
end

eltype(::Type{MultipleEdgeIter{AbstractMultigraph{T, U}}}) where {T<:Integer, U<:Integer} = MultipleEdge{T, U}

function iterate(eit::MultipleEdgeIter{G}, state=(one(eltype(eit.g)), one(eltype(eit.g)))) where {G <: AbstractMultigraph}
    g = eit.g
    n = nv(g)
    u, i = state

    @inbounds while u <= n
        list_u = outneighbors(g, u)
        if i > length(list_u)
            u += 1
            i = one(u)
            continue
        end
        if is_directed(g)
            e = MultipleEdge(u, list_u[i], g.adjmx[u, list_u[i]])
            state = (u, i + 1)
            return e, state
        else
            if list_u[i] >= u
                e = MultipleEdge(u, list_u[i], g.adjmx[u, list_u[i]])
                state = (u, i + 1)
                return e, state
            else
                i += 1
            end
        end
    end

    if n == 0 || u > n
        return nothing
    end
end
