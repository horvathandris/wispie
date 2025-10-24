# 🪶 wispie

[![Package Version](https://img.shields.io/hexpm/v/wispie)](https://hex.pm/packages/wispie)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/wispie/)

A tiny Gleam library for rendering [🧚 wisp](https://hex.pm/packages/wisp) **HTTP responses** into readable text snapshots.
Designed for use with [🐦‍⬛ birdie](https://hex.pm/packages/birdie) snapshot testing,
but also handy for **debugging** and **logging**.

## ✨ Features

- Converts `response.Response(wisp.Body)` into a nicely formatted string.
- Includes status, headers, and body — all in one view.
- Automatically detects and formats body content:
  - `wisp.Text` → pretty-printed based on content type (`application/json`, `text/html`, etc.)
  - `wisp.Bytes` → UTF-8 decoded when possible.
  - `wisp.File` → compact file reference with offset and limit.
- Integrates seamlessly with **Birdie snapshot tests**.
- Uses [`contenty`](https://hex.pm/packages/contenty) for robust `Content-Type` parsing.

## 🧩 Installation

```sh
gleam add wispie@1
```

## 🚀 Usage

```gleam
import gleam/http/response
import wisp
import wispie
import birdie

pub fn json_response_snapshot__test() {
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
  |> birdie.snap("json_response")
}
```

produces a clean snapshot like

```
201
content-type: application/json

{
  "id": "123",
  "name": "John Doe"
}
```


Further documentation can be found at <https://hexdocs.pm/wispie>.

## 🧑‍💻 Development

```sh
gleam test  # Run the tests
```

## 🧰 Related
- [🧚 wisp](https://hex.pm/packages/wisp) – A practical web framework for Gleam
- [🐦‍⬛ birdie](https://hex.pm/packages/birdie) – Snapshot testing in Gleam
- [🧾 contenty](https://hex.pm/packages/contenty) – HTTP Content-Type parsing in Gleam
