using Graphs
using GraphPlot


###################################################
## Graph: IN/OUT
###################################################

function Read_undirected_Graph_DIMACS(filename)

    g=SimpleGraph(1)	 # Creation of an undirected graph with 1 node

    open(filename) do f
       
           for (i,line) in enumerate(eachline(f))
              x = split(line," ") # For each line of the file, splitted using space as separator
              if(x[1]=="p")       # A line beginning with a 'p' gives the graph size
                  n = parse(Int,x[3])
                  g = SimpleGraph(n)  # Recreation of a undirected graph with n nodes
              elseif(x[1] == "e") # A line beginning with a 'e' gives the edges
                  v_1 = parse(Int, x[2])
                  v_2 = parse(Int, x[3])
                  add_edge!(g,v_1,v_2)
                  #g.weights[v_1,v_2] = 1  # without edge weight
               end
           end
    end
    return g
end


function Read_directed_Graph_GRA(filename)

    g=SimpleDiGraph(1)	 # Creation of a directed graph with 1 node

    open(filename) do f
       
           for (i,line) in enumerate(eachline(f))
              x = split(line," ") # For each line of the file, splitted using space as separator
              if (i==1)
                  n = parse(Int,x[1])  # Read the number of nodes
                  g = SimpleDiGraph(n)  # Recreation of a directed graph with n nodes
              else
                  j=3
                  while (j<size(x)[1]-1)
                    v_1 = parse(Int, x[1])
                    v_2 = parse(Int, x[j])
                    add_edge!(g,v_1+1,v_2+1)   # in this case an edge is oriented as an arc
                    #g.weights[v_1+1,v_2+] = 1  # without arc weight
                    j=j+1
                  end
              end
           end
    end
    return g
end




function WritePdf_visualization_Graph(G,filename)

filename_splitted_in_two_parts = split(filename,".") # split to remove the file extension
filename_with_pdf_as_extension= filename_splitted_in_two_parts[1]*".pdf"
# save to pdf
draw(PDF(filename_with_pdf_as_extension, 16cm, 16cm), gplot(G, nodelabel = 1:nv(G)))
end





