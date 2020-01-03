using Test, Circo, CSV

@testset "DataFrames" begin
    filename = joinpath(@__DIR__, "onecolumn.csv")
    workflow = CSV.read(filename) | (row -> 2 * row.col1)
    @test workflow() == 88
    biggerflow = CSV.read(filename) | ((row -> 2 * row.col1) | (x->2x))
    @test biggerflow() == 176
end
