using BKMaxflow

weights, neighbors = create_graph(JuliaImpl{Float64,Int}, 4)

BKMaxflow.add_edge!(weights, neighbors, 1, 2, 1., 1.)
BKMaxflow.add_edge!(weights, neighbors, 1, 3, 2., 2.)
BKMaxflow.add_edge!(weights, neighbors, 2, 3, 3., 4.)
BKMaxflow.add_edge!(weights, neighbors, 2, 4, 5., 5.)
BKMaxflow.add_edge!(weights, neighbors, 3, 4, 6., 6.)

w = reshape(weights, 2, :)
flow, label = boykov_kolmogorov(1, 4, neighbors, w)

println(flow)
println(label)
