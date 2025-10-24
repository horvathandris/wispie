import contenty
import glam/doc
import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import gleam/string_tree
import simplejson
import simplejson/jsonvalue

pub fn format_file(
  path: String,
  offset: Int,
  limit: option.Option(Int),
) -> String {
  string_tree.new()
  |> string_tree.append("Path: ")
  |> string_tree.append(path)
  |> string_tree.append("\nOffset: ")
  |> string_tree.append(int.to_string(offset))
  |> string_tree.append("\nLimit: ")
  |> string_tree.append(option.map(limit, int.to_string) |> option.unwrap(""))
  |> string_tree.to_string
}

pub fn format_content(
  content: String,
  content_type: option.Option(contenty.ContentType),
) -> String {
  case content_type {
    option.Some(content_type) ->
      case contenty.mime_subtype(content_type) |> string.ends_with("json") {
        True -> format_json(content)
        _ -> content
      }
    option.None -> content
  }
}

fn format_json(content: String) -> String {
  case simplejson.parse(content) {
    Error(_) -> "!!! Failed to parse JSON !!!"
    Ok(parsed) ->
      json_to_doc(parsed)
      |> doc.to_string(1)
  }
}

fn json_to_doc(json: jsonvalue.JsonValue) -> doc.Document {
  case json {
    jsonvalue.JsonArray(entries) ->
      dict.values(entries)
      |> array_to_doc
    jsonvalue.JsonBool(bool:) -> bool_to_doc(bool)
    jsonvalue.JsonNull -> doc.from_string("null")
    jsonvalue.JsonNumber(int:, float:, original:) ->
      number_to_doc(int, float, original)
    jsonvalue.JsonObject(fields) ->
      dict.to_list(fields)
      |> object_to_doc
    jsonvalue.JsonString(str:) -> doc.from_string("\"" <> str <> "\"")
  }
}

fn comma() -> doc.Document {
  doc.from_string(",")
}

fn colon() -> doc.Document {
  doc.from_string(":")
}

fn number_to_doc(
  int: option.Option(Int),
  float: option.Option(Float),
  original: option.Option(String),
) -> doc.Document {
  option.map(int, int.to_string)
  |> option.or(option.map(float, float.to_string))
  |> option.or(original)
  |> option.map(doc.from_string)
  |> option.lazy_unwrap(fn() { doc.from_string("\"NaN\"") })
}

fn bool_to_doc(value: Bool) -> doc.Document {
  bool.to_string(value)
  |> string.lowercase
  |> doc.from_string
}

fn array_to_doc(objects: List(jsonvalue.JsonValue)) -> doc.Document {
  list.map(objects, json_to_doc)
  |> doc.concat_join(with: [comma(), doc.space])
  |> parenthesise("[", "]")
}

fn object_to_doc(fields: List(#(String, jsonvalue.JsonValue))) -> doc.Document {
  list.map(fields, field_to_doc)
  |> doc.concat_join(with: [comma(), doc.space])
  |> parenthesise("{", "}")
}

fn field_to_doc(field: #(String, jsonvalue.JsonValue)) -> doc.Document {
  let #(name, value) = field
  let name_doc = doc.from_string(name)
  let value_doc = json_to_doc(value)
  [name_doc, colon(), doc.from_string(" "), value_doc]
  |> doc.concat
}

fn parenthesise(doc: doc.Document, open: String, close: String) -> doc.Document {
  doc
  |> doc.prepend_docs([doc.from_string(open), doc.space])
  |> doc.nest(by: 2)
  |> doc.append_docs([doc.space, doc.from_string(close)])
  |> doc.group
}
