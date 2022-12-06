function clark_wright(params,demands,costs,t)
    n = params["n"]
    Q = params["Q"]
    S = [[0, i] for i in 1:n]
    whereIs = Dict(i => circuit for (i, circuit) in enumerate(S))
    s=[]
    for i in 1:n, j in 1:n
        if i != j
            push!(s, [ (i,j), costs[1, i+1] + costs[1, j+1] - costs[i+1, j+1] ]) # pb indices
        end
    end
    sort!(s, by = x->x[2], rev=true)
    for k in 1:length(s)
        i=s[k][1][1]
        j=s[k][1][2]
        ci = whereIs[i]
        cj = whereIs[j]
        if cj != ci
            ici = findfirst(item -> item == ci, S)
            icj = findfirst(item -> item == cj, S)
            cu = union(S[ici], S[icj])
            demandeUnion=0
            for l in cu[2:end]
                demandeUnion += demands[l][t]
            end
            if demandeUnion <= Q
                deleteat!(S, sort!([ici, icj]))
                push!(S, cu)
                for index in cu
                    push!(whereIs, index=>cu)
                end
            end
        end
    end
    return S
end