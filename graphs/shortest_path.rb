# determine the distance (in number of edges) between two vertices in a graph.

# -----------------------------------------------------------------------------
# algorithm
# -----------------------------------------------------------------------------

=begin
  - we assume that both source and target are vertices of the graph.
  - what if there is no path connecting source and target? return nil.
  - do a breadth-first search of the graph starting at v1.
  - we keep track of the distance of the nodes we enqueue: the distance of a
    vertex to the source is 1 + the distance of its parent vertex to the source.
  - we check whether we have found the target as we dequeue.
  - (we could just as well do this check as we enqueue a node, I suppose). 

=end

# -----------------------------------------------------------------------------
# solution
# -----------------------------------------------------------------------------

def distance(graph, source, target)
  queue = Queue.new
  queue.enq(source)
  visited = { source => true}
  distances = { source => 0 }

  while !queue.empty?
    vtx = queue.deq
    return distances[vtx] if vtx == target
    graph[vtx].each do |neighbor|
      queue.enq(neighbor) unless visited[neighbor]
      distances[neighbor] = distances[vtx] + 1
      visited[neighbor] = true
    end
  end

  return nil
end

# -----------------------------------------------------------------------------
# simplified solution
# -----------------------------------------------------------------------------

# we don't need a separate `visited` hash, as the `distances` hash already
# has the information whether we have visited a hash.

def distance(graph, source, target)
  queue = Queue.new
  queue.enq(source)
  distances = { source => 0 }

  while !queue.empty?
    vtx = queue.deq
    return distances[vtx] if vtx == target # processing step
    graph[vtx].each do |neighbor|
      queue.enq(neighbor) unless distances[neighbor]
      distances[neighbor] = distances[vtx] + 1
    end
  end

  return nil
end

# we could process the vertex as we enqueue it. then we need to take care of
# case where source equals target separately.

# -----------------------------------------------------------------------------
# tests
# -----------------------------------------------------------------------------

graph =
{
  'a' => ['b', 'c'],
  'b' => ['d', 'e'],
  'c' => ['f', 'g'],
  'd' => [],
  'e' => [],
  'f' => [],
  'g' => [],
}

p distance(graph, 'a', 'a') == 0
p distance(graph, 'a', 'c') == 1
p distance(graph, 'a', 'd') == 2
p distance(graph, 'a', 'f') == 2
