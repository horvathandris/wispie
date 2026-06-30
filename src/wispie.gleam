import contenty
import gleam/bit_array
import gleam/bytes_tree
import gleam/http
import gleam/http/response
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/string_tree
import wisp
import wispie/internal/pretty_print
import wispie/internal/string_tree_util

/// Converts an HTTP `response.Response(wisp.Body)` into a human-readable string.
///
/// This function renders the full HTTP response snapshot, including:
/// - **Status code**
/// - **Headers**
/// - **Body**, formatted according to its `Content-Type`
///
/// Body rendering rules:
/// - `wisp.Text` bodies are pretty-printed based on their content type (e.g. JSON, HTML).
/// - `wisp.Bytes` bodies are decoded as UTF-8 when possible; otherwise a placeholder is shown.
/// - `wisp.File` bodies are displayed as a formatted file reference with offset and limit.
///
pub fn response_to_string(response: response.Response(wisp.Body)) -> String {
  string_tree.new()
  |> string_tree.append(format_status(response.status))
  |> string_tree_util.append_if_present("\n", format_headers(response.headers))
  |> string_tree_util.append_if_present("\n\n", format_body(response))
  |> string_tree.to_string
}

fn format_status(status: Int) -> String {
  int.to_string(status)
}

fn format_headers(headers: List(http.Header)) -> String {
  headers
  |> list.map(fn(header) { header.0 <> ": " <> header.1 })
  |> string.join("\n")
}

fn format_body(response: response.Response(wisp.Body)) -> String {
  let content_type =
    get_content_type(response)
    |> option.from_result

  case response.body {
    wisp.Text(content) -> pretty_print.format_content(content, content_type)
    wisp.Bytes(bytes) ->
      case
        bytes_tree.to_bit_array(bytes)
        |> bit_array.to_string
      {
        Error(_) -> "!!! Invalid UTF-8 Response Body !!!"
        Ok(content) -> content
      }
    wisp.File(path:, offset:, limit:) ->
      pretty_print.format_file(path, offset, limit)
  }
}

fn get_content_type(
  response: response.Response(wisp.Body),
) -> Result(contenty.ContentType, Nil) {
  case response.get_header(response, "content-type") {
    Ok(content_type_header) ->
      contenty.parse(content_type_header)
      |> result.replace_error(Nil)
    Error(e) -> Error(e)
  }
}
