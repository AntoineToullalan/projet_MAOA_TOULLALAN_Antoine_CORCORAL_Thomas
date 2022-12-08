using JuMP
using CPLEX
using CPUTime

include("Graph_StableSet.jl")

function PLNE_compact_StableSet(G)

   m = Model(CPLEX.Optimizer)

   @variable(m, x[1:nv(G)], Bin)

   @objective(m, Max, sum(x[i] for i = 1:nv(G) ) )

   for e in edges(G)
       @constraint(m, x[src(e)] + x[dst(e)] <= 1 )
   end

   print(m)
   println()

   optimize!(m)
   
   println(solution_summary(m, verbose=true))

   status = termination_status(m)

   if status == JuMP.MathOptInterface.OPTIMAL
       println("Valeur optimale = ", objective_value(m))
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
       println("Temps de résolution :", solve_time(m))
       return S
   else
      println("Problème lors de la résolution")
   end

end

##########################
### Launch compact PLNE and visualization for the stable set problem
##########################

function Find_exact_StableSet(filename)

 G=Read_undirected_Graph_DIMACS(filename)

 @time @CPUtime S=PLNE_compact_StableSet(G)

 WritePdf_visualisation_Stable(G,S,filename)

end
