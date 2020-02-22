using Multigraphs, LightGraphs, SparseArrays
using Test

# @testset "Multigraphs.jl" begin
#     # Write your own tests here.
# end

@testset "multiple_edge.jl" begin
    me = MultipleEdge(1, 2, 3)
    try
        MultipleEdge(1, 2, 0)
    catch err
        @test err != nothing
    end
    @test src(me) == 1 && dst(me) == 2 && mul(me) == 3
    e0 = LightGraphs.SimpleEdge(me)
    @test e0 == MultipleEdge(1, 2)
    @test e0 == MultipleEdge([1, 2])
    @test e0 == MultipleEdge([1, 2, 1])
    @test e0 == MultipleEdge((1, 2))
    @test e0 == MultipleEdge((1, 2, 1))
    @test e0 == MultipleEdge(1 => 2)
    @test reverse(me) == MultipleEdge(2, 1, 3)
    @test eltype(me) == Int

    @test [e0 == e for e in me] == [true for i = 1:mul(me)]
    @test Tuple(me) == (1,2,3)
    length(me) == mul(me)
end

@testset "multigraph.jl" begin
    try
        m2 = spzeros(Int, 2, 3)
        dg = Multigraph(m2)
    catch e
        @test e != nothing
    end
    try
        m2 = spzeros(Int, 2, 2)
        m2[1, 2] = 2
        dg = Multigraph(m2)
    catch e
        @test e != nothing
    end
    try
        m2 = spzeros(Int, 2, 2)
        m2[1, 2] = -1
        m2[2, 1] = -1
        dg = Multigraph(m2)
    catch e
        @test e != nothing
    end

    m = spzeros(Int, 4, 4)
    m[1,2] = 2
    m[2,1] = 2
    m[2,3] = 2
    m[3,2] = 2
    m[3,4] += 1
    m[3,4] = 0
    m[4,3] += 1
    m[4,3] = 0
    g = Multigraph(m)
    g = Multigraph(Matrix(m))

    g0 = Multigraph(2)
    @test !add_edge!(g0, 2, 3) && !rem_edge!(g0, 1, 2)
    g1 = Multigraph(path_graph(3))

    @test !is_directed(g)
    @test edgetype(g) == MultipleEdge{Int, Int}
    @test size(adjacency_matrix(g), 1) == 4

    i = 0
    for me in edges(g)
        for e in me
            i += 1
        end
        # println(me)
    end
    @test multype(g) == Int
    @test i == 4
    ne(g)
    @test nv(g) == 4 && ne(g, true) == 4 && ne(g) == 2

    add_vertices!(g,3)
    @test nv(g) == 7

    @test has_edge(g, 1, 2, 2)
    @test rem_vertices!(g, [1, 5, 4, 6, 8]) == [2, 3, 7]
    add_edge!(g, [2, 3, 2])
    rem_edge!(g, [2, 3, 2])
    add_edge!(g, 2, 3)
    rem_edge!(g, 2, 3)
    add_edge!(g, 2, 3, 2)
    rem_edge!(g, 2, 3, 1)

    @test has_edge(g, 2, 3) && has_edge(g, [2, 3])
    @test !has_edge(g, 2, 3, 2) && !has_edge(g, (2, 3, 2))
    @test !has_edge(g, 2, 2) && !has_edge(g, 2, 5)
    @test has_vertex(g, 1) && !has_vertex(g, 5)
    for v in vertices(g)
        @test inneighbors(g, v) == outneighbors(g, v)
        @test degree(g, v) == indegree(g, v) && indegree(g, v) == outdegree(g, v)
    end
    add_vertex!(g)
end

@testset "di_multigraph.jl" begin
    try
        m2 = spzeros(Int, 2, 3)
        dg = DiMultigraph(m2)
    catch e
        @test e != nothing
    end
    try
        m2 = spzeros(Int, 2, 2)
        m2[1, 2] = -1
        dg = DiMultigraph(m2)
    catch e
        @test e != nothing
    end

    m = spzeros(Int, 4, 4)
    m[1,2] = 2
    m[2,1] = 1
    m[2,3] = 3
    # m[3,2] = 4
    m[3,4] += 1
    m[3,4] = 0
    m[4,3] += 1
    m[4,3] = 0
    g = DiMultigraph(m)
    g = DiMultigraph(Matrix(m))
    g0 = DiMultigraph(2)
    g1 = DiMultigraph(path_digraph(3))
    @test is_directed(g) && is_directed(g0)

    i = 0
    for me in edges(g)
        for e in me
            i += 1
        end
        # println(me)
    end
    @test multype(g) == Int
    @test i == 6

    @test outneighbors(g, 2) == [1, 3]
    @test inneighbors(g, 2) == [1]
    @test outdegree(g, 2) == 4 && indegree(g, 2) == 2 && degree(g, 2) == 6
    @test degree(g) == indegree(g) + outdegree(g)

    @test nv(g) == 4 && ne(g, true) == 6 && ne(g) == 3
    @test !add_edge!(g0, 2, 3) && !rem_edge!(g0, 2, 3)

    add_vertices!(g,3)
    @test nv(g) == 7

    @test has_edge(g, 1, 2, 2)
    @test rem_vertices!(g, [1, 5, 4, 6, 8]) == [2, 3, 7]
    add_edge!(g, 2, 3, 2)
    rem_edge!(g, 2, 3, 1)

    @test has_edge(g, 2, 3)
    @test !has_edge(g, 2, 3, 2)
    @test !has_edge(g, 2, 2)
end
