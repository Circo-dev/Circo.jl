using DataFrames

function tosourcefunction(df::DataFrame)::SourceFunction
    return (superstep) -> df[superstep, :],
           (superstep) -> nrow(df) >= superstep
end

(|)(source::DataFrame, f::Function)::Network = begin
    tosourcefunction(source) | f
end

(|)(source::DataFrame, n::Network)::Network = begin
    tosourcefunction(source) | n
end
