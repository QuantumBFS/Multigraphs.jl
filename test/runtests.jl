using Multigraphs, LightGraphs, SparseArrays
using Test

@testset "Multigraphs.jl" begin
    # Write your own tests here.
end

@testset "multigraph.jl" begin
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
    @test nv(g) == 4 && ne(g, true) == 4 && ne(g) == 2

    add_vertices!(g,3)
    @test nv(g) == 7

    @test has_edge(g, 1, 2, 2)
    @test rem_vertices!(g, [1, 5, 4, 6, 8]) == [2, 3, 7]

    @test has_edge(g, MultipleEdge(1,2))
    # @test has_
end
