using Test, Circo, CSV

@testset "DataFrames" begin
    workflow = CSV.read("test/assets/onecolumn.csv") | (row -> 2 * row.col1)
    @test workflow() == 88
end
