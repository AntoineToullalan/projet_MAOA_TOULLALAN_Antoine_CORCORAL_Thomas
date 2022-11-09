using JuMP
using CPLEX

include("Graph_Acyclic.jl")

include("BandC_AcyclicSeparationAlgo.jl")

# MOI is a shortcut for MathematicalOptimizationInterface

function BandC_Acyclic(G)

    LP = Model(CPLEX.Optimizer)
  
    # Setting some stat variables
    nbViolatedAcyclicCst_fromIntegerSep = 0
    nbViolatedAcyclicCst_fromFractionalSep = 0
     
    # Setting the Model LP

    #variables
    @variable(LP, x[1:nv(G)], Bin)        
    # objective function
    @objective(LP, Max, sum(x[i] for i = 1:nv(G) ) )

    # 2-node circuit inequalities
    #x_i + x_j <= 1 for all circuit ( (i,j) , (j,i) ) if there exists some

   for e in edges(G)
       if has_edge(G, dst(e), src(e))
          @constraint(LP, x[dst(e)] + x[src(e)] <= 1 )
       end
   end

 
#   println(LP)

  #################
  # our function lazySep_ViolatedAcyclicCst
    function lazySep_ViolatedAcyclicCst(cb_data)
        # cb_data is the CPLEX value of our variables for the separation algorithm
        # In the case of a LazyCst, the value is integer, but sometimes, it is more 0.99999 than 1

        # Get the x value from cb_data and round it
        xsep=[0 for i in 1:nv(G)]
        for i in 1:nv(G)
           if (callback_value(cb_data, x[i])>0.999)
             xsep[i]=1
           end
        end
       # for i in 1:nv(G)
       #   print(xsep[i]," ")
       # end
       # println()
        
        violated, C = ViolatedAcyclic_IntegerSeparation(G,xsep)

        con = @build_constraint(sum(x[C[i]] for i = 1 : length(C) ) <= length(C) - 1)
        #println(con)

        if ( violated ) 
         MOI.submit(LP, MOI.LazyConstraint(cb_data), con) 
         nbViolatedAcyclicCst_fromIntegerSep=nbViolatedAcyclicCst_fromIntegerSep+1
        end
        
    end
  #
  #################


  #################
  # our function userSep_ViolatedAcyclicCst
    function userSep_ViolatedAcyclicCst(cb_data)
        # cb_data is the CPLEX value of our variables for the separation algorithm
        # In the case of a usercut, the value is fractional or integer (and can be -0.001)

        # Get the x value from cb_data 
        xsep=[0.0 for i in 1:nv(G)]
        for i in 1:nv(G)
           xsep[i]=callback_value(cb_data, x[i])   
        end
        #for i in 1:nv(G)
        #  print(xsep[i]," ")
        #end
        #println()
        
        L = ViolatedAcyclic_FractionalSeparation(G,xsep)
        #println("L=",L)
        for C in L
           con = @build_constraint(sum(x[C[i]] for i = 1 : length(C) ) <= length(C) - 1)
           #println(con)
           MOI.submit(LP, MOI.UserCut(cb_data), con) 
           nbViolatedAcyclicCst_fromFractionalSep=nbViolatedAcyclicCst_fromFractionalSep+1
        end
        
    end
  #
  #################

  #################
  # our function primalHeuristicAcyclic
    function primalHeuristicAcyclic(cb_data)
    
        L=[]
        for i in 1:nv(G)
           push!(L, ( i , callback_value(cb_data, x[i]) ) )
        end
        sort!(L, by = x -> x[2])

        sol=[0 for i in 1:nv(G)]

        # The following loop has an awfully complexity of O(n^2+nm)
        # There is another possibility with a code similar to
        # the Kruskall Union-Find structure in O(n+m)
        # Since this heurisitic is often used in the code
        # it will be really mandatory to give her the smallest complexity
        # or to encode a this place another cheaper heuristic
        
        # Greedy algorithm
        cpt=0
        for (i,v) in L
           sol[i]=1
           cycle, C= return_circuit(G,sol)
           if (cycle)
              sol[i]=0;
           end
          cpt=cpt+1
        end

        MOI.submit(LP, MOI.HeuristicSolution(cb_data), x, sol)
    
    end
  #
  #################

  #################
  # Setting callback in CPLEX
    # our lazySep_ViolatedAcyclicCst function sets a LazyConstraintCallback of CPLEX
    MOI.set(LP, MOI.LazyConstraintCallback(), lazySep_ViolatedAcyclicCst) 
    
    # our userSep_ViolatedAcyclicCst function sets a LazyConstraintCallback of CPLEX   
    MOI.set(LP, MOI.UserCutCallback(), userSep_ViolatedAcyclicCst)
    
    # our primal heuristic to "round up" a primal fractional solution
    MOI.set(LP, MOI.HeuristicCallback(), primalHeuristicAcyclic)
  #
  #################


    optimize!(LP)

    #println(LP)

    println("optimum = ", objective_value(LP))  
    S = Bool[]
    for i= 1:nv(G)
       println("\t x[",i,"] = ", value(x[i]))
       if (value(x[i])<0001) 
         push!(S,0)
       else
         push!(S,1)
       end
     end
    println("Temps de résolution :", solve_time(LP))
    println("Number of generated acyclic constraints  : ", nbViolatedAcyclicCst_fromIntegerSep+nbViolatedAcyclicCst_fromFractionalSep)
    println("   from IntegerSep:", nbViolatedAcyclicCst_fromIntegerSep)
    println("   from FractionalSep:", nbViolatedAcyclicCst_fromFractionalSep)
  
    return S
end




##########################
### Launch compact PLNE and visualization for the stable set problem
##########################

function Find_exact_Acyclic_BandC(filename)

 G=Read_directed_Graph_GRA(filename)

 @time @CPUtime S=BandC_Acyclic(G)

 WritePdf_visualization_Acyclic(G,S,filename)

end
