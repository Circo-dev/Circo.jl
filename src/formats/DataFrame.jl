using DataFrames

function tosourcefunction(df::DataFrame)::SourceFunction
    return (step)->df[step, :],
           (step)->nrow(df) >= step
end

(|)(source::DataFrame, f::Function)::Network = begin
    tosourcefunction(source) | f
end

(|)(source::DataFrame, n::Network)::Network = begin
    tosourcefunction(source) | n
end
