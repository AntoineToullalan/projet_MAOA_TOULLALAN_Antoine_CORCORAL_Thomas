using JuMP
using CPLEX

include("Graph_Acyclic.jl")

function PLNE_compact_Acyclic(G)

   m = Model(CPLEX.Optimizer)

   @variable(m, x[1:nv(G)], Bin)
   @variable(m, u[1:nv(G)])

   @objective(m, Max, sum(x[i] for i = 1:nv(G) ) )

   for e in edges(G)
       @constraint(m, u[dst(e)] - u[src(e)] + 1 <= nv(G)*(2-x[src(e)]-x[dst(e)]) )
   end

   for i in 2:nv(G)
      @constraint(m, 1<=u[i]<=nv(G))
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

function Find_exact_Acyclic_compactPLNE(filename)

 G=Read_directed_Graph_GRA(filename)

 @time @CPUtime S=PLNE_compact_Acyclic(G)

 WritePdf_visualization_Acyclic(G,S,filename)

end
