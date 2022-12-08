
###################################################
## Graph: Specific algorithms
###################################################

function return_circuit_from_r(G,r,v_label,T, cpt, cycle,extr)

if (cycle==false)
  cpt=cpt+1
    
  v_label[r]=1          
  
  i=1
  n=length(outneighbors(G,r))
  while ( (!cycle) && (i<=n) )
      j=outneighbors(G,r)[i]

      if (v_label[j]==0) 
         T[j]=r
         cycle, extr, T, cpt = return_circuit_from_r(G,j,v_label,T,cpt,cycle,extr)
      elseif (v_label[j]==1)
          cycle=true
          extr=j
          T[j]=r
          return cycle, extr, T, cpt
      end
      i=i+1
  end
  v_label[r]=2
end  
return cycle, extr, T, cpt
  
end

function return_circuit(G,sol)

  cycle=false

  v_label=[-1 for i in 1:nv(G)]
  T=[-2 for i in 1:nv(G)]

  
  totnode=0
  for i in 1:nv(G)
    if (sol[i]==1)
       v_label[i]=0 # no-visited node
       totnode=totnode+1
    end
  end

  cpt=0
  extr=-1  #sera le depart du circuit s'il existe

  while ( (!cycle) && (cpt!=totnode) )

    i=1
    while (v_label[i]!=0)
      i=i+1
    end
   T[i]=-1
   cycle, extr, T, cpt = return_circuit_from_r(G,i,v_label,T,cpt,cycle,extr)

  end

  C=Int[]
  if (cycle)
    i=extr
    push!(C,i)
    i=T[i]
    while (i!=extr)
      push!(C,i)
      i=T[i]
    end
  end
 
  return cycle, C

end


###################################################
## Separation algorithm
###################################################



function ViolatedAcyclic_IntegerSeparation(G,xsep)

  violated, C= return_circuit(G,xsep)

  return violated, C

end


function ViolatedAcyclic_FractionalSeparation(G,xsep)

  L=[]

  # Randomly scrumble the nodes of G 

  lotohat=[i for i in 1:nv(G)]  
  for i in 1:nv(G)
   j=rand(1:nv(G))
    k=lotohat[i]
    lotohat[i]=lotohat[j]
    lotohat[j]=k
  end

  # Put the linear relaxation values on the edges of graph G
  
  edgecost = zeros(nv(G),nv(G))
  for i in 1:nv(G)
     for j in 1:nv(G)
         edgecost[i,j] = (2-xsep[i]-xsep[j])/2.0
         if (edgecost[i,j]<0.0001) 
            edgecost[i,j]=0
         end
     end
  end
               
  # Find a shortest circuit for every node i

  i=1
  while ( (length(L)<200) && (i<nv(G)) )
    
    # Shortest Path Tree rooted in lotohat[i] found by Dijkstra algorithm
    SPT=dijkstra_shortest_paths(G,lotohat[i], edgecost)
    
    for j in 1:nv(G)

      if ( (j!=lotohat[i]) && (SPT.parents[j]!=0) && (has_edge(G,j,lotohat[i])) )

	  test=SPT.dists[j]+(2-xsep[lotohat[i]]-xsep[j])/2.0
          
	  if (test<0.999) 
	    # Found a violated inequality -> add to violatedCst structure
	    C=[]
	    u=j
	    while (u!=0)
	      push!(C,u)
	      u=SPT.parents[u]
	    end
            #println("C= ",C)
	    push!(L,C)

	  end
      end

    end
    i=i+1

  end
  
  return L

end
