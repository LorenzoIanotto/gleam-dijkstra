# dijkstra

<!-- Future development -->
<!-- [![Package Version](https://img.shields.io/hexpm/v/dijkstra)](https://hex.pm/packages/dijkstra) -->
<!-- [![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/dijkstra/) -->

```sh
gleam add dijkstra
```

```gleam
import dijkstra.{type Graph, Adjacency}
import gleam/io
import gleam/result

pub fn main() {
  let graph: Graph = [
    Adjacency("A", "B", 6), Adjacency("A", "D", 1), Adjacency("B", "A", 6),
    Adjacency("B", "D", 2), Adjacency("B", "C", 5), Adjacency("B", "E", 2),
    Adjacency("C", "B", 5), Adjacency("C", "E", 5), Adjacency("D", "A", 1),
    Adjacency("D", "B", 2), Adjacency("D", "E", 1), Adjacency("E", "B", 2),
    Adjacency("E", "C", 5), Adjacency("E", "D", 1), Adjacency("Z", "Y", 2),
  ]

  let shortest_a_c: Graph = [
    Adjacency("A", "D", 1), Adjacency("D", "E", 1), Adjacency("E", "C", 5),
  ]

  let shortest_path = dijkstra.shortest_path(graph, "A", "C")
    |> result.unwrap([])

  io.debug(shortest_a_c == shortest_path)
}
```

<!-- Future development -->
<!-- Further documentation can be found at <https://hexdocs.pm/dijkstra>. -->

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
