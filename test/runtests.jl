using Multigraphs, LightGraphs, SparseArrays
using Test

@testset "multiple_edge.jl" begin
    include("multiple_edge.jl")
end

@testset "multigraph_adjlist.jl" begin
    include("multigraph_adjlist.jl")
end

@testset "multiple_edge_iter.jl" begin
    include("multiple_edge_iter.jl")
end

@testset "di_multigraph.jl" begin
    
end
