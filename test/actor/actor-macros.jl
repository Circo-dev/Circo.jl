using Circo
using Test

@testset "Actor" begin
    @testset "Actor-Macros" begin
        @message Start
        @test Start == Message{Nothing}
        @message GrowRequest{ComponentId}
        @test GrowRequest == Message{ComponentId}
        @message struct GrowResponse
            leafsgrown::Vector{ComponentId}
        end
        @test typeof(GrowResponseBody) == DataType
        @test GrowResponse == Message{GrowResponseBody}
    end
end