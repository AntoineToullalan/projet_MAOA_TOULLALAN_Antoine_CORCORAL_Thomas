using Graphs
using Cairo, Compose, Fontconfig, GraphPlot, Colors # package for graph plotting
using Random
using CPUTime

include("Graph_Manip.jl")


# Write a PDF with a stable set S of graph G
# S is a 1-dimension array with value 0 or 1
function WritePdf_visualization_Acyclic(G,S,filename)

  #nodescolor= Array{Colors.Colorant,1}(undef,nv(G))
  nodescolor=[colorant"lightgrey" for i in 1:nv(G)]

  for v in 1:nv(G)
     if (S[v]==1)
         nodescolor[v]= colorant"red"
     end
  end

 edgecolors = [colorant"lightgray" for i in 1:ne(G)] #e in edges(G)]
 i=1
 for e in edges(G)
   if (S[dst(e)]==1 && S[src(e)]==1)
      edgecolors[i] = colorant"black"
   end
   i=i+1
 end

  
  filename_splitted_in_two_parts = split(filename,".") # split to remove the file extension
  filename_with_pdf_as_extension= filename_splitted_in_two_parts[1]*"_acyclic.pdf"
  # save to pdf
  draw(PDF(filename_with_pdf_as_extension, 16cm, 16cm), gplot(G, nodefillc=nodescolor, edgestrokec=edgecolors, nodelabel = 1:nv(G), arrowlengthfrac=0.05))
end


