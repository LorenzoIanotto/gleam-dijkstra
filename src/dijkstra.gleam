//// This module contains a simple oriented and weighted graph type and a Dijkstra Shortest Path algorithm implementation

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub type Node =
  String

/// A simple connection between to nodes (oriented and weighted)
pub type Adjacency {
  Adjacency(start: Node, end: Node, cost: Int)
}

pub type Graph =
  List(Adjacency)

type TableEntry {
  TableEntry(
    node: Node,
    current_min_cost: Int,
    predecessor: Option(Node),
    visited: Bool,
  )
}

type Table =
  List(TableEntry)

/// Returns the shortest path
pub fn shortest_path(graph: Graph, start: Node, end: Node) -> Result(Graph, Nil) {
  let table: Table = [TableEntry(start, 0, None, False)]

  use final_table <- result.try(visit_next_node(graph, start, end, table))
  reconstruct_path(final_table, start, end)
}

fn visit_next_node(
  graph: Graph,
  start: Node,
  end: Node,
  table: Table,
) -> Result(Table, Nil) {
  // Current entry is selected as the unvisited node with minimum total cost
  let current_entry: Option(TableEntry) =
    list.filter(table, fn(e) { !e.visited })
    |> list.fold(None, fn(prev: Option(TableEntry), current) {
      case prev {
        None -> Some(current)
        Some(prev) ->
          case current.current_min_cost < prev.current_min_cost {
            True -> Some(current)
            False -> Some(prev)
          }
      }
    })
  use current_entry <- result.try(option.to_result(current_entry, Nil))

  // All unvisited adjacencies from the current node
  let adjacency_from_current_node =
    list.filter(graph, fn(a) {
      let end_visited = {
        let result = list.find(table, fn(e) { e.node == a.end })
        case result {
          Error(_) -> False
          Ok(e) -> e.visited
        }
      }
      a.start == current_entry.node && !end_visited
    })

  // Construct the new table
  // The already visited entries remain the same
  // Also the entries which are not adjacent to the current remain the same
  // The current entry is set as visited
  // The remaining entries (adjacent and unvisited) change if the path from the current node is cheaper
  let new_table =
    adjacency_from_current_node
    |> list.map(fn(a) {
      let other_node = a.end
      let entry = list.find(table, fn(e) { e.node == other_node })
      let cost_from_current_to_other = current_entry.current_min_cost + a.cost

      case entry {
        Error(_) ->
          TableEntry(
            node: other_node,
            current_min_cost: cost_from_current_to_other,
            predecessor: Some(current_entry.node),
            visited: False,
          )
        Ok(other_entry) ->
          case cost_from_current_to_other < other_entry.current_min_cost {
            True ->
              TableEntry(
                ..other_entry,
                current_min_cost: cost_from_current_to_other,
                predecessor: Some(current_entry.node),
              )
            False -> other_entry
          }
      }
    })
    |> list.append(
      list.filter_map(table, fn(e) {
        case e.node == current_entry.node {
          True -> Ok(TableEntry(..current_entry, visited: True))
          False ->
            case
              e.visited
              || {
                list.find(adjacency_from_current_node, fn(a) { a.end == e.node })
                |> result.is_error
              }
            {
              True -> Ok(e)
              False -> Error(Nil)
            }
        }
      }),
    )

  case current_entry.node == end {
    True -> Ok(new_table)
    False -> visit_next_node(graph, start, end, new_table)
  }
}

/// Constructs a path (sub-graph) from a Dijkstra SP result
fn reconstruct_path(table: Table, start: Node, end: Node) -> Result(Graph, Nil) {
  use end_entry <- result.try(list.find(table, fn(e) { e.node == end }))
  reconstruct_path_recursive(table, start, end_entry)
}

/// Constructs a path (sub-graph) from a Dijkstra SP result.
/// The "end" param is an entry so we can calculate the cost of an adjacency
/// without looking at the graph (an additional param)
/// or searching for the entry of the same node two times between function calls,
/// making it more performant
fn reconstruct_path_recursive(
  table: Table,
  start: Node,
  end: TableEntry,
) -> Result(Graph, Nil) {
  use predecessor <- result.try(
    end.predecessor
    |> option.to_result(Nil),
  )

  case predecessor == start {
    True -> Ok([Adjacency(predecessor, end.node, end.current_min_cost)])
    False -> {
      use predecessor_entry <- result.try(
        list.find(table, fn(e) { e.node == predecessor }),
      )

      use previous_part <- result.try(reconstruct_path(
        table,
        start,
        predecessor,
      ))

      Ok(
        list.append(previous_part, [
          Adjacency(
            predecessor,
            end.node,
            end.current_min_cost - predecessor_entry.current_min_cost,
          ),
        ]),
      )
    }
  }
}
