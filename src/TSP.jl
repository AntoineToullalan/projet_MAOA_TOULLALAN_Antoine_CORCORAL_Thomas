using JuMP
using CPLEX
using CPUTime
using Graphs
import HiGHS

function LSP(prp, optim="CPLEX")
    if optim == "HiGHS"
        LP = Model(HiGHS.Optimizer)
    elseif optim == "CPLEX"
        LP = Model(CPLEX.Optimizer)
    else
        return -1
    end

    n = prp["Clients"].nb_clients      # Nombre de clients (usine inclue)
    l = prp["l"]                       # Nombre de périodes - t appartient(0, ..., l)
    
    @variable(LP, y_dec[1:l], Bin)
    @variable(LP, p_dec[1:l] >= 0)
    @variable(LP, I_dec[1:n, 1:l] >=0, Int)
    @variable(LP, q_dec[1:n, 1:l] >= 0)
    
    # Objective Function
    
    @objective(LP, Min, sum(prp["u"] * p_dec[t] + 
            prp["f"] * y_dec[t] + 
            sum(prp["Clients"].h[i] * I_dec[i, t] for i in 1:n) for t in 1:l))
    
    # Constraint (2)
    
    for t in 1:l
        if t>1
            @constraint(LP, I_dec[1, t-1] + p_dec[t] == sum(q_dec[i, t] for i in 2:n) + I_dec[1, t]) # (1)
            @constraint(LP, I_dec[1, t-1] <= prp["Clients"].L[1]) # (4)
        else
            @constraint(LP, prp["Clients"].L0[1] + p_dec[t] == sum(q_dec[i, t] for i in 2:n) + I_dec[1, t]) # (1)
            @constraint(LP, prp["Clients"].L0[1] <= prp["Clients"].L[1]) # (4)
        end
        for i in 1:n
            if i > 1
                if t>1
                    @constraint(LP, I_dec[i, t-1] + q_dec[i, t] == prp["Clients"].d[i][t] + I_dec[i, t]) # (2)
                    @constraint(LP, I_dec[i, t-1] + q_dec[i, t] <= prp["Clients"].L[i]) # (5)
                else
                    @constraint(LP, prp["Clients"].L0[i] + q_dec[i, t] == prp["Clients"].d[i][t] + I_dec[i, t]) # (2)
                    @constraint(LP, prp["Clients"].L0[i] + q_dec[i, t] <= prp["Clients"].L[i]) # (5)
                end
                Mit = min(prp["Clients"].L[i], prp["Q"], sum(prp["Clients"].d[i][j] for j in t:l))
            end
        end
        Mt = min(prp["C"], sum(sum(prp["Clients"].d[i][j] for i in 2:n) for j in t:l))
        @constraint(LP, p_dec[t] <= Mt * y_dec[t]) # (3)
    end
    return LP
end