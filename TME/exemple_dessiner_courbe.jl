#= Programme permettant de construire une courbe à partir 
   de couples (x_i,y_i) de données.
   Ces couples sont rassemblées dans un fichier où
   chaque paire compose une ligne avec un espace entre 2 nombres.
   Un fichier exemple donnees.txt peut être trouvé sur le site du TP
   Le programme se lance par la fonction Dessine_courbe avec en paramètre
   le nom du fichier de données.
=#

# Le package Plots va nous permettre de dessiner
# mais il faut auparavant avoir taper: import Pkg; Pkg.add("Plots")

ENV["GKSwstype"] = "nul"  # redirige les sorties de Plots vers les fichiers et non à l'écran
using Plots


# Fonction qui lit un fichier de données et renvoie le nombre de données et la liste des données

function Lit_fichier_données(nom_fichier, tabX, tabY)

  open(nom_fichier) do f
        
        for (i,line) in enumerate(eachline(f)) 
              lg = split(line," ")      # découpe la ligne suivant les espaces et crée un tableau 
	      x= parse(Float16,lg[1])   # traduit la lecture texte en un réel
              y= parse(Float16,lg[2])
              push!(tabX,x)             # ajoute la donnée au tableau-liste le ! évoque le fait que tabX est modifié
              push!(tabY,y)
        end
    
  end
  return size(tabX)[1]
end


# Fonction Dessine_courbe

function Dessine_courbe(nom_fichier)

    tabX= Float16[]
    tabY= Float16[]

    println("Lecture du fichier: ", nom_fichier)

    n=Lit_fichier_données(nom_fichier, tabX, tabY)

    println("Le fichier contient ",n, " paires de données")
  
    nom_fichier_en_deux_morceaux = split(nom_fichier,".") # découpe le nom du fichie d'entrée sans l'extension
    nom_fichier_avec_pdf_a_la_fin= nom_fichier_en_deux_morceaux[1]*".pdf"

    println("Création du fichier de courbes: ", nom_fichier_avec_pdf_a_la_fin)

    Plots.plot(tabX,tabY)
    Plots.savefig(nom_fichier_avec_pdf_a_la_fin)  # Ecrit la courbe créée à la ligne précédente dans un fichier .pdf

end    
