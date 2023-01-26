using Multigraphs, Graphs, SparseArrays
using Test
try
    m2 = spzeros(Int, 2, 3)
    dg = DiMultigraph(m2)
catch e
    @test e !== nothing
end
try
    m2 = spzeros(Int, 2, 2)
    m2[1, 2] = 2
    dg = DiMultigraph(m2)
catch e
    @test e === nothing
end
try
    m2 = spzeros(Int, 2, 2)
    m2[1, 2] = -1
    m2[2, 1] = -1
    dg = DiMultigraph(m2)
catch e
    @test e !== nothing
end

m = spzeros(Int, 4, 4)
m
m[1,2] = 2
m[2,1] = 1
m[2,3] = 2
m[3,2] = 1
m[3,4] += 1
m[3,4] = 0
m[4,3] += 1
m[4,3] = 0
g = DiMultigraph(m)
g = DiMultigraph(Matrix(m))
g0 = DiMultigraph(2)
@test !add_edge!(g0, 2, 3) && !rem_edge!(g0, 1, 2)
g1 = DiMultigraph(path_digraph(3))
@test adjacency_matrix(g) == m

@test is_directed(g)
@test edgetype(g) == MultipleEdge{Int, Int}
@test size(adjacency_matrix(g), 1) == 4

@test nv(g) == 4 && ne(g, count_mul = true) == 6 && ne(g) == 4

add_edge!(g1, 1, 1, 2)
@test ne(g1, count_mul = true) == 4 && ne(g1) == 3

add_vertices!(g, 3)
@test nv(g) == 7

@test has_edge(g, 1, 2, 2)
@test rem_vertices!(g, [7, 5, 4, 6])
add_edge!(g, [2, 3, 2])
rem_edge!(g, [2, 3, 2])
add_edge!(g, 2, 3)
rem_edge!(g, 2, 3)
add_edge!(g, 2, 3, 2)
rem_edge!(g, 2, 3, 1)

@test has_edge(g, 2, 3) && has_edge(g, [2, 3])
@test has_edge(g, 2, 3, 2) && has_edge(g, (2, 3, 2))
@test !has_edge(g, 2, 2) && !has_edge(g, 2, 5)
@test has_vertex(g, 1) && !has_vertex(g, 5)

collect(edges(g))
@test inneighbors(g, 2) == outneighbors(g, 2)
@test degree(g, 2) != indegree(g, 2)
add_vertex!(g)
@test indegree(g) != outdegree(g)

dmg0 = DiMultigraph(0)
@test nv(dmg0) == ne(dmg0) == 0

#test constructor
@test try DiMultigraph(1); true; catch; false; end
@test try DiMultigraph{Int}(1); true; catch; false; end
@test try DiMultigraph(); true; catch; false; end
@test try DiMultigraph{Int}(); true; catch; false; end

