using DataFrames

function tosourcefunction(df::DataFrame)::SourceFunction
    return (globalstep) -> df[globalstep, :],
           (globalstep) -> nrow(df) >= globalstep
end

(|)(source::DataFrame, f::Function)::Network = begin
    tosourcefunction(source) | f
end

(|)(source::DataFrame, n::Network)::Network = begin
    tosourcefunction(source) | n
end
