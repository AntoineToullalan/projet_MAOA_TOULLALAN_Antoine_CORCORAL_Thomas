using Graphs


function dist(C, i, j, t, mc)
    if(t == 1)
        return ((C.X[i] - C.X[j])^2 + (C.Y[i] - C.Y[j])^2)^(0.5) + 0.5
    else
        return ((C.X[i] - C.X[j])^2 + (C.Y[i] - C.Y[j])^2)^(0.5) * mc
    end
end


function calcul_dist(p)
    if(p["Type"] == 1)
        mc = 0
    else
        mc = p["mc"]
    end
    c = Array{Float64}(undef, (p["n"]+1, p["n"]+1))
    for i in 1:p["n"]+1
        for j in 1:p["n"]+1            
            c[i, j] = dist(p["Clients"], i, j, p["Type"], mc)
        end
    end
    return c
end