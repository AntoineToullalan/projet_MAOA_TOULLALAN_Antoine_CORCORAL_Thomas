import numpy as np
#notre méthode reprensentant la métaheuristique C-W prend en argument les couts c, une solution initiale et les clients à desservir

def solution_initiale(n_clients):
    #on note 0 le dépot
    solution=[]
    for client in range(n_clients):
        solution+=[0,client,0]
    return solution

def calcul_sij(c,d,alpha, beta, gamma):
    n=len(c)
    d_somme=sum(d)
    s= np.zeros((n-1,n-1)).tolist()
    #on regarde i parmi les clients donc on évite 0
    for i in range(1,n):
        #on regarde j parmi les clients donc on évite 0
        for j in range(1,i):
            s[i-1][j-1]=c[0,i]+c[0,j] - alpha*c[i,j] + beta*abs(c[0,i]+c[0,j]) + gamma*(d[i]+d[j])/d_somme
            s[j-1][i-1]=s[i-1][j-1]
    return s

def retourne_valeur_min_sij(s,deja_visite_s):
    #deja_visite_s est une liste de la forme [[i1,j1],[i2,j2]...] de i,j déjà visité
    minimum=1e10
    i_res=-1
    j_res=-1
    for i in range(len(s)):
        for j in range(i):
            if(s[i,j]<minimum and not (i,j) in deja_visite_s):
                minimum=s[i,j]
                i_res=i
                j_res=j
    return (i_res+1,j_res+1) #on rajoute 1 car on cherche les identifiants des clients

def cherche_circuit(chemin):
    elem=chemin[-1]
    res=[]
    i=0
    for elem2 in chemin[:-1]:
        if elem2 == elem:
            return chemin[i:].copy()
        i+=1
            
            
        
def reperage_circuits(chemin):
    circuits=[]
    i=0
    for noeud in chemin:
        if noeud in chemin[:i]:
            circuits+=cherche_circuit(chemin[:i+1])
        i+=1
    return circuits
        
def circuits_differents(i,j,circuits):
    for circuit in circuits:
        if(i in circuit and j in circuit):
            return False
    return True

def heuristique_Clark_Wright(c,d,alpha_beta_gamma,capacite_camion):
    
    #alpha beta gamma doivent être compris entre 0 et 2
    alpha,beta,gamma=alpha_beta_gamma
    alpha=max(min(alpha,2),0)
    beta=max(min(beta,2),0)
    alpha=max(min(gamma,2),0)
    
    deja_visite_s=[]
    nb_clients=len(c)-1
    sol = solution_initiale(nb_clients)
    s=calcul_sij(c,d,alpha, beta, gamma)
    
    for _ in range(nb_clients*nb_clients):
        circuits=reperage_circuits(sol)

        i,j=retourne_valeur_min_sij(s,deja_visite_s)
        deja_visite_s.append((i,j))
        while(circuits_differents(i,j,circuits)):
            
    
    
    
    
    
            
        
            
        

