using JuMP
using CPLEX

# Définition de constantes pour le statut de résolution du problème
const OPTIMAL = JuMP.MathOptInterface.OPTIMAL
const INFEASIBLE = JuMP.MathOptInterface.INFEASIBLE
const UNBOUNDED = JuMP.MathOptInterface.DUAL_INFEASIBLE;

# Création d'un modèle. Ce modèle fera l'interface avec le solveur CPLEX
# Vous pouvez aussi utiliser GLPK ou GUROBI ou CBC ou ...
m = Model(CPLEX.Optimizer)

#Création d'une variable x dans le modèle m. x est une variable continue positive.
@variable(m, 0 <= x)

#Création d'une deuxième variable continue y entre 0 et 30
@variable(m, 0 <= y <= 30 )

#Création de la fonction objective du modèle
@objective(m, Max, 7x + 2y )

#=
ATTENTION : 2 écritures possibles : 5x + 3y ou 5 * x + 3 * y.
            Par contre, 5 x + 3 y produit une erreur
=#


#Ajout d'une contrainte dans le modèle
@constraint(m, c1, 4x + 2y <= 2.5 )  # Il est important de nommer les variables pour récupérer la solution duale
@constraint(m, c2, 3x + 4y <= 6 )
@constraint(m, c3, x + 5y == 3.5 )


#Affichage du modèle
println("Affichage du modèle avant résolution:")
print(m)
println()

#Résolution du problème d'optimisation linéaire m par le solveur GLPK
println("Résolution par le solveur linéaire choisi")
optimize!(m)
println()

# Affiche tous les détails d'une solution à l'écran
println("Affichage de tous les détails de la solution avec la commande solution_summary")
println(solution_summary(m, verbose=true))
println()


# Mais on peut vouloir récupérer juste une information précise
println("Récupération et affichage \"à la main\" d'informations précises")
status = termination_status(m)

if status == INFEASIBLE
    println("Le problème n'est pas réalisable")
elseif status == UNBOUNDED
    println("Le problème est non borné")
elseif status == OPTIMAL
    println("Valeur optimale = ", objective_value(m))
    println("Solution primale optimale :")
    println("\t x = ", value(x))
    println("\t y = ", value(y))
    println("Solution duale optimale :")
    println("\t c1 = ", -dual(c1)) # la fonction dual renvoie le coût réduit qui est l'opposé de la variable duale en maximisation
    println("\t c2 = ", -dual(c2))
    println("\t c3 = ", -dual(c3))
    println("Temps de résolution :", solve_time(m))
else
    println("Problème lors de la résolution")
end

