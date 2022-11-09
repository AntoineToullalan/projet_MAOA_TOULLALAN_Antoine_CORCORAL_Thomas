using JuMP
using CPLEX

include("Graph_Acyclic.jl")

function PLNE_test(G)

   LP= Model(CPLEX.Optimizer)


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

 
   print(LP)
   println()


   optimize!(LP)
   
   println(solution_summary(LP, verbose=true))

   status = termination_status(LP)

   if status == JuMP.MathOptInterface.OPTIMAL
       println("Valeur optimale = ", objective_value(LP))
       println("Solution primale optimale :")
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
       return S
   else
      println("Problème lors de la résolution")
   end

end

##########################
### Launch compact PLNE and visualization for the stable set problem
##########################

function tes(filename)

 G=Read_directed_Graph_GRA(filename)

 @time @CPUtime S=PLNE_test(G)

 WritePdf_visualization_Acyclic(G,S,filename)

end
