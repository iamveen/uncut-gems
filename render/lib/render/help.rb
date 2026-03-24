# frozen_string_literal: true

module Render
  module Help
    def self.text
      <<~HELP
        RENDER v#{Render::VERSION}
        CLI template engine for transforming JSON into formatted output.

        OVERVIEW

          render reads JSON from stdin, applies an ERB template, and writes the rendered
          result to stdout. Templates are .erb files with YAML frontmatter that defines
          metadata and a JSON Schema describing the expected input.

          Input is validated against the schema before rendering. Errors are written to
          stderr. Rendered output goes to stdout, making render composable with pipelines
          and LLM agents.

        TEMPLATE FORMAT

          A template file has two sections separated by --- delimiters:

            1. YAML frontmatter  - metadata and input schema
            2. ERB body          - the template to render

          Required frontmatter fields:

            name         Identifier for the template
            description  Human-readable description of what the template renders
            schema       JSON Schema for the expected input (used for validation)

          The schema supports nested objects, arrays of objects, and all standard JSON
          Schema types (string, integer, number, boolean, array, object, null).

          Example template (movie.erb):

            ---
            name: movie-card
            description: Movie details card
            schema:
              type: object
              properties:
                title:
                  type: string
                year:
                  type: integer
                cast:
                  type: array
                  items:
                    type: object
                    properties:
                      name: {type: string}
                      role: {type: string}
                    required: [name]
              required: [title]
            ---
            Title: <%= title %>
            Year:  <%= year %>
            <% if cast %>
            Cast:
            <% cast.each do |actor| %>
              - <%= actor["name"] %><%= " as \#{actor["role"]}" if actor["role"] %>
            <% end %>
            <% end %>

          ERB context:

            Top-level JSON keys are available as local variables in the template.

              JSON input:              {"title": "Hello", "year": 2024}
              ERB usage:               <%= title %>, <%= year %>

            Nested objects use standard Ruby hash syntax:

              JSON input:              {"movie": {"title": "The Matrix"}}
              ERB usage:               <%= movie["title"] %>

            Arrays iterate with standard Ruby blocks:

              JSON input:              {"items": [{"name": "Alice"}, {"name": "Bob"}]}
              ERB usage:               <% items.each do |item| %>
                                         - <%= item["name"] %>
                                       <% end %>

        COMMANDS

          render apply <template>
            Read JSON from stdin, validate against the template schema, render the
            template, and write the result to stdout. Validation runs before rendering —
            if the input does not match the schema, the template is never rendered.

            Arguments:
              <template>   Path to the .erb template file

            Stdin:         JSON object
            Stdout:        Rendered text output
            Stderr:        Error messages

            Exit codes:
              0  Success — template rendered, output written to stdout
              1  Template not found at the given path
              2  Invalid JSON input (stdin could not be parsed)
              3  Validation failed — input does not match template schema
              4  Template rendering error (ERB raised an exception)

          render schema <template>
            Output the template's name, description, and schema as a YAML document.
            Useful for inspecting what a template expects before piping data to it.

            Arguments:
              <template>   Path to the .erb template file

            Stdout:        YAML document with name, description, schema

            Exit codes:
              0  Success
              1  Template not found at the given path

          render validate <template>
            Validate JSON from stdin against the template's schema without rendering.
            Prints "Valid" to stdout on success. Prints validation errors to stderr on
            failure. Useful for pre-flight checks in pipelines.

            Arguments:
              <template>   Path to the .erb template file

            Stdin:         JSON object
            Stdout:        "Valid" on success
            Stderr:        Validation error messages on failure

            Exit codes:
              0  Valid — input matches the schema
              1  Invalid — input does not match schema, or error (bad JSON, not found)

          render check <template>
            Validate the template file itself. Runs four checks in order:

              1. Frontmatter — YAML syntax is valid
              2. Required fields — name, description, schema are all present
              3. Schema — the schema is a valid JSON Schema
              4. ERB — the template body is valid ERB/Ruby syntax

            Useful during template development. All check results are reported even if
            an early check fails (except ERB, which is skipped if frontmatter is broken).

            Arguments:
              <template>   Path to the .erb template file

            Stdout:        "Template OK" on success
            Stderr:        Per-check error messages on failure

            Exit codes:
              0  Template OK — all checks passed
              1  Template has errors — one or more checks failed

        EXIT CODES SUMMARY

          apply     0=ok  1=not found  2=bad json  3=invalid input  4=render error
          schema    0=ok  1=not found
          validate  0=valid  1=invalid or error
          check     0=ok  1=errors

        EXAMPLES

          # Render a simple template
          echo '{"title": "The Matrix", "year": 1999}' | render apply ./movie.erb

          # Validate input before rendering (separate step)
          echo '{"title": "Test"}' | render validate ./movie.erb

          # Validate and render in one pipeline (short-circuits on invalid input)
          DATA='{"title": "Test"}' && \\
            echo "$DATA" | render validate ./movie.erb && \\
            echo "$DATA" | render apply ./movie.erb

          # Inspect what a template expects
          render schema ./movie.erb

          # Check a template for errors during development
          render check ./movie.erb

          # Pipe output from another CLI tool
          plex library items | jq -c '{title, year}' | render apply ./movie.erb

          # Render multiple objects from NDJSON (one render per line)
          ndjson_source | while IFS= read -r line; do
            echo "$line" | render apply ./movie.erb
          done

      HELP
    end
  end
end
