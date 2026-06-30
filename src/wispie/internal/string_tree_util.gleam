import gleam/string_tree

pub fn append_if_present(
  tree: string_tree.StringTree,
  separator: String,
  content: String,
) -> string_tree.StringTree {
  case content {
    "" -> tree
    _ ->
      tree
      |> string_tree.append(separator)
      |> string_tree.append(content)
  }
}
