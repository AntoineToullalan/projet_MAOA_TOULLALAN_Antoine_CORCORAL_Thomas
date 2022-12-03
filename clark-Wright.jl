

#=
Retourne une liste de tournées qui vérifie la contrainte de poids sur les véhicules
Le nombre de tournée peut toutefois excéder le nombre de véhicules disponible.
Note: Version plus rapide mais qui prend un peu plus de mémoire
=#
function clark_wright(params,nodes,demands,costs,t)

	n = params["n"]
	Q = params["Q"]

	#Initialiser S
	S = [[0, i] for i in 1:n]
	whereIs = Dict(i => circuit for (i, circuit) in enumerate(S))

	#Calcul des s_{i,j} et mettre dans l'ordre décroissant
	s=[]
	for i in 1:n, j in 1:n
		if i != j
			push!(s, [ (i,j), costs[(0, i)] + costs[(0, j)] - costs[(i, j)] ])
		end
	end
	
	sort!(s, by = x->x[2], rev=true) #by = key pour sort, rev = reverse (ordre décroissant)

	#Construction des circuits (attention il peut en avoir plus de m (le nombre de camion disponible))
	for k in 1:length(s)

		i=s[k][1][1]
		j=s[k][1][2]

		circuit_i = whereIs[i]
		circuit_j = whereIs[j]

		#Si i et j ne sont pas dans le même circuit
		if circuit_j != circuit_i

			index_circuit_i = findfirst(item -> item == circuit_i, S)
			index_circuit_j = findfirst(item -> item == circuit_j, S)

			circuit_union = union(S[index_circuit_i], S[index_circuit_j])

			#Calcul demande du nouveau circuit circuit_union
			demandeUnion=0 
			for l in circuit_union[2:end] #commence à 2 car le premier noeud du circuit est 0 (le dépot n'a pas de demande)
				demandeUnion += demands[l, t]
			end

			#Si la demande du nouveau circuit n'est pas trop pour un seul camion
			if demandeUnion <= Q
				
				deleteat!(S, sort!([index_circuit_i, index_circuit_j]))

				push!(S, circuit_union)


				for index in circuit_union
					push!(whereIs, index=>circuit_union)
				end

			end
		end

	end

	return S #la liste des circuits qui sont des tournées valides (qui respectent la contrainte de poids)
end