import birdie
import gleam/option
import gleeunit
import wisp
import wispie

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn response_to_string_418_hello_world__test() {
  let simple_hello_world_response =
    wisp.response(418)
    |> wisp.string_body("Hello, World!")
    |> wisp.set_header("Content-Type", "text/plain")

  simple_hello_world_response
  |> wispie.response_to_string
  |> birdie.snap("200_hello_world")
}

pub fn response_to_string_201_json_response__test() {
  let response_body =
    "
    {
      \"id\": \"123\",
      \"name\": \"John Doe\"
    }
    "

  let response = wisp.json_response(response_body, 201)

  response
  |> wispie.response_to_string
  |> birdie.snap("201_json_response")
}

pub fn response_to_string_200_file_response__test() {
  let response =
    wisp.response(200)
    |> wisp.set_body(wisp.File("/some/path/to/file.txt", 0, option.Some(64)))

  response
  |> wispie.response_to_string
  |> birdie.snap("200_file_response")
}

pub fn response_to_string_204_no_content__test() {
  let response = wisp.response(204)

  response
  |> wispie.response_to_string
  |> birdie.snap("204_no_content")
}
