
using DelimitedFiles ,GraphRecipes, Plots
using Graphs
using GraphPlot
using Colors
using ITensors

# Specify the path to your text file
home_directory = homedir()
relative_path = "plutonotebooks/adiabaticqaoa/MCN8K3S17.txt"
file_path = joinpath(home_directory, relative_path)
# Use readdlm to read the matrix from the file
matrix = readdlm(file_path, ' ')
println(matrix)

function read_graph_data(filename)
    data = filename
    num_vertices = data[2, 1]
    edge_data = data[3:end, :]
    return num_vertices, edge_data
end

	# Create a graph from the edge data
function create_graph(num_vertices, edge_data)
    graph = SimpleGraph(num_vertices)
    for row in eachrow(edge_data)
        add_edge!(graph, row[1], row[2])
    end
    return graph
end

# Create an adjacency matrix from the edge data
function create_adjacency_matrix(num_vertices, edge_data)
    adj_matrix = zeros(Int, num_vertices, num_vertices)
    for row in eachrow(edge_data)
        adj_matrix[row[1], row[2]] = 1
        adj_matrix[row[2], row[1]] = 1
    end
    return adj_matrix
end

# Read graph data
num_vertices, edge_data = read_graph_data(matrix)

# Create the graph
graph = create_graph(num_vertices, edge_data)

function ob_func(edge_data::Matrix)
    s1,s2 = size(edge_data)
    os = OpSum()
    for ii in 1:s1
        v1 = edge_data[ii,1]
        v2 = edge_data[ii,2]
        w = edge_data[ii,3]
        os += w*0.5, "Id", v1, "Id", v2 
        os -= w*0.5, "Z", v1, "Z", v2
      end
      return os
end

function mix_func(N)
    os = OpSum()
    for ii in 1:N
        os += "X", ii
      end
      return os
end