function binPacking(prp, t)
    cumsum = 0
    set = Vector{Int64}[]
    subset = [0]
    for i in 2:prp["n"]+1
        cumsum += prp["Clients"].d[i][t]
        if cumsum > prp["Q"]
            push!(set, subset)
            cumsum = demand
            subset = [0]
        end
        push!(subset, i)
    end
    if length(subset) > 1
        push!(set, subset)
    end
    return set
end