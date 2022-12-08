using Graphs
using Cairo, Compose, Fontconfig, GraphPlot, Colors # package for graph plotting
using Random
using CPUTime

include("Graph_Manip.jl")

const epsilon = 0.001
const MAX_ITER = 10000
const MAX_ITER_IMPROV = 1000

# Write a PDF with a stable set S of graph G
# S is a 1-dimension array with value 0 or 1
function WritePdf_visualisation_Stable(G,S,filename)

  nodescolor= Array{Colors.Colorant,1}(undef,nv(G))

  for v in 1:nv(G)
     if (S[v]==1)
         nodescolor[v]= colorant"red"
     elseif  (S[v]<epsilon)
         nodescolor[v]= colorant"lightgrey"
     end
  end

  filename_splitted_in_two_parts = split(filename,".") # split to remove the file extension
  filename_with_pdf_as_extension= filename_splitted_in_two_parts[1]*"_stable.pdf"
  # save to pdf
  draw(PDF(filename_with_pdf_as_extension, 16cm, 16cm), gplot(G, nodefillc=nodescolor, nodelabel = 1:nv(G)))

end

# GREEDY HEURISTIC
function Graph_StableSet_greedy_heuristic(G)

  greedy_sol = Array{Bool,1}(undef,nv(G)) 
  V_nbvois= Array{Int64,1}(undef,nv(G))

  
  for i =1:nv(G)
    greedy_sol[i]=0
    V_nbvois[i]=0
  end
  
  val_greedy_sol=0

  for i =1:nv(G)
    if (V_nbvois[i]==0)
      greedy_sol[i]=1
      val_greedy_sol=val_greedy_sol+1

      for j in neighbors(G,i)
	V_nbvois[j]=V_nbvois[j]+1
      end
    end
  end

  println("Greedy solution: : ", val_greedy_sol)

  return greedy_sol
					    
end

# META-HEURISTIC starting from a stable set S
function Graph_StableSet_metaheuristic(G,S)

  curr_sol = Array{Bool,1}(undef,nv(G)) 
  best_sol = Array{Bool,1}(undef,nv(G)) 
  V_nbvois = Array{Int64,1}(undef,nv(G))

  val_S=0
  for i=1:nv(G)  
    best_sol[i]=S[i]
    if S[i]==1
       val_S=val_S+1
    end
  end
  val_best_sol=val_S


  for nb=0:MAX_ITER
  
    for i=1:nv(G)
       V_nbvois[i]=0
    end

    for i=1:nv(G)  
       curr_sol[i]=S[i]
       for j in neighbors(G,i)
           V_nbvois[j]=V_nbvois[j]+1
       end
    end
    val_curr_sol=val_S
        
    cpt_non_improv=0;

    while (cpt_non_improv<MAX_ITER_IMPROV)

      cpt_non_improv=cpt_non_improv+1

      cand=rand(1:nv(G))
      
      if ( (rand((1,2))==1) && (curr_sol[cand]==0) ) # Adding attempt

        found=true
        for j in neighbors(G,cand)
           if (curr_sol[j]==1)
             found=false
             break
           end
        end
        if (found)
	  curr_sol[cand]=1;
	  val_curr_sol=val_curr_sol+1
          for j in neighbors(G,cand)	
	    V_nbvois[j]=V_nbvois[j]+1
          end
        end

      else                                           # deleting attempt
	if ( (curr_sol[cand]==1) && ( rand(1:100)<20) ) 
	  curr_sol[cand]=0
          for j in neighbors(G,cand)
	    V_nbvois[j]=V_nbvois[j]-1
          end
 	  val_curr_sol=val_curr_sol-1
	end
      end
  
      if (val_curr_sol>val_best_sol)
	for i = 1:nv(G)
            best_sol[i]=curr_sol[i]
        end
	val_best_sol=val_curr_sol
	cpt_non_improv=0;
        println("   Iteration ", nb, " : New Value found ",val_best_sol)
      end


      
    end

  end
  println("End of MetaHeuristic")

 return best_sol

end

##########################
### Launch Heuristic and visualization for the stable set problem
##########################

function Find_Heuristic_StableSet(filename)

 G=Read_undirected_Graph_DIMACS(filename)

 @time @CPUtime S=Graph_StableSet_greedy_heuristic(G)

 @time @CPUtime S=Graph_StableSet_metaheuristic(G,S)

 WritePdf_visualisation_Stable(G,S,filename)

end
