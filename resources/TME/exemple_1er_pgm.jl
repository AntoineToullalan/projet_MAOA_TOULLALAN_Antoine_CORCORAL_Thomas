# Un premier programme en Julia avec une fonction et une boucle for

# Fonction qui écrit n fois une chaine passée en paramètre
# On peut voir qu'il n'y a pas besoin de typer les variables

function Affiche_n_fois_une_chaine(n,chaine)

   # Dans cette boucle for, la variable i prend les valeurs de 1,2,3,4..n
   for i = 1:n
      println(chaine)
   end

end


# Les lignes qui ne sont pas dans une fonction vont être exécutées
# C'est donc le programme principale

# DEBUT PROGRAMME PRINCIPAL

machaine="Bonjour"
Affiche_n_fois_une_chaine(3, machaine)

# FIN PROGRAMME PRINCIPAL
    
