# given a connected undirected network, find a minimum spanning tree of the network using prim's algorithm.

# -----------------------------------------------------------------------------
# definitions
# -----------------------------------------------------------------------------

=begin

- a *network* is a graph with a non-negative integer assigned to
  each edge.
- a graph is *connected* if there is a path connecting every pair of
  vertices.
- a graph is *undirected* if if its symmetric.
- a *spanning tree* of an undirected connected graph G is an acyclic subgraph
  of G.
- a *minimum spanning tree* of a network N is a spanning tree T of N with
  minimum weight (i.e., the sum of the edges of T is less than or equal the
  sum of the edges of any spanning tree of N).

=end

# -----------------------------------------------------------------------------
# prim algorithm
# -----------------------------------------------------------------------------

=begin

- prepare a list `to_pick` containing every vertex in the graph (exactly once)
- pick an arbitrary vertex from the list (and remove it from the list), and
  add it to a new graph `tree` (with all the vertices, and adjacency lists initialized to empty arrays)
- while there are vertices left to pick:
  - pick the cheapest edge expanding the tree with a new vertex
  - update the tree with the edge
- return the tree

=end

# -----------------------------------------------------------------------------
# data structure
# -----------------------------------------------------------------------------

# we are going to represent a graph as a pair (vertices, edges), where the edges are labeled and thus given as triples:

[ [:a, 10, :b], [:a, 10, :c], [:c, 10, :a], [:b, 10, :a] ]

# so given an edge edge = [:a, 10, :c],
# - edge[0] is the origin of the edge,
# - edge[1] is the weight of the edge,
# - edge[2] is the destination of the edge.

# -----------------------------------------------------------------------------
# an attempt at implementing prim's algorithm
# -----------------------------------------------------------------------------

def minimum_spanning_tree(vertices, edges)
  to_pick = vertices.dup
  to_pick.pop
  tree = []
  while !to_pick.empty?
    choices = edges.select do |edge|
      !to_pick.include?(edge[0]) && to_pick.include?(edge[2])
    end
    greedy_choice = choices.min_by { |edge| edge[1] }
    tree += [greedy_choice, greedy_choice.reverse]
    to_pick.delete(greedy_choice[2])
  end
  tree
end

# the weak point of this algorithm is the way we manage the choices. we
# compute them from scratch on each iteration of the while loop. it would be
# better to maintain a set of choices, adding and removing elements as the
# algorithm proceeds. another weak point is the delete-operations on the
# to_pick-array. this could be improved by using a hash flagging what vertices
# may still be picked.

# -----------------------------------------------------------------------------
# tests
# -----------------------------------------------------------------------------

vertices = [:a, :b, :c, :d]

edges = [
  [:a, 1, :b],
  [:a, 2, :d],
  [:a, 5, :c],
  [:b, 1, :a],
  [:c, 5, :a],
  [:c, 3, :d],
  [:d, 2, :a],
  [:d, 3, :c],
]

p minimum_spanning_tree(vertices, edges)

# [[:d, 3, :c], [:c, 3, :d], [:c, 5, :a], [:a, 5, :c], [:a, 1, :b], [:b, 1, :a]]
