import dijkstra.{type Graph, Adjacency}
import gleam/result
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// A unoriented graph (adjacency are duplicated, one for each direction)
const graph: Graph = [
  Adjacency("A", "B", 6), Adjacency("A", "D", 1), Adjacency("B", "A", 6),
  Adjacency("B", "D", 2), Adjacency("B", "C", 5), Adjacency("B", "E", 2),
  Adjacency("C", "B", 5), Adjacency("C", "E", 5), Adjacency("D", "A", 1),
  Adjacency("D", "B", 2), Adjacency("D", "E", 1), Adjacency("E", "B", 2),
  Adjacency("E", "C", 5), Adjacency("E", "D", 1), Adjacency("Z", "Y", 2),
]

const shortest_a_c: Graph = [
  Adjacency("A", "D", 1), Adjacency("D", "E", 1), Adjacency("E", "C", 5),
]

/// DSP works correctly when the start and the end are connected,
/// returning the shortest path
pub fn correct_shortest_path_test() {
  dijkstra.shortest_path(graph, "A", "C")
  |> result.unwrap([])
  |> should.equal(shortest_a_c)
}

/// DSP gives an error when trying to find an impossible path
pub fn unreachable_path_test() {
  dijkstra.shortest_path(graph, "C", "Z")
  |> should.be_error
}
