# render

A CLI template engine for transforming JSON data into formatted output via ERB
templates.

## Overview

`render` reads JSON from stdin, applies an ERB template, and writes the result to
stdout. Templates include a YAML frontmatter block that defines a name, description, and
JSON Schema for their expected input.

## Installation

```bash
cd render
bundle install
gem build render.gemspec
gem install ./render-*.gem
rm ./render-*.gem
```

## Commands

| Command | Description |
| --- | --- |
| `render apply <template>` | Render stdin JSON through a template |
| `render schema <template>` | Show template schema as YAML |
| `render validate <template>` | Validate stdin JSON against template schema |
| `render check <template>` | Validate the template file itself |

## Template Format

Templates are ERB files with a YAML frontmatter block:

```
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
          name:
            type: string
          role:
            type: string
        required:
          - name
  required:
    - title
---
Title: <%= title %>
Year:  <%= year %>
<% if cast %>
Cast:
<% cast.each do |actor| %>
  - <%= actor["name"] %><%= " as #{actor["role"]}" if actor["role"] %>
<% end %>
<% end %>
```

### Frontmatter Fields

| Field | Required | Description |
| --- | --- | --- |
| `name` | Yes | Template identifier |
| `description` | Yes | Human-readable description |
| `schema` | Yes | JSON Schema for expected input |

### ERB Context

All top-level keys from the JSON input are available as local variables in the template:

```erb
<%# JSON: {"title": "Hello", "year": 2024} %>
Title: <%= title %>
Year:  <%= year %>
```

Nested objects and arrays are accessed via standard Ruby hash syntax:

```erb
<%# JSON: {"movie": {"title": "The Matrix"}} %>
<%= movie["title"] %>

<%# JSON: {"items": [{"name": "Alice"}]} %>
<% items.each do |item| %>
  - <%= item["name"] %>
<% end %>
```

## Usage Examples

### Basic rendering

```bash
echo '{"title": "The Matrix", "year": 1999}' | render apply ./templates/movie.erb
```

### Validate input before rendering

```bash
echo '{"missing": "field"}' | render validate ./templates/movie.erb
# Validation failed:
#   - missing required field(s): title

echo $?  # => 1
```

### Check a template for errors

```bash
render check ./templates/movie.erb
# Template OK

render check ./templates/broken.erb
# Frontmatter: Invalid YAML: ...
# ERB: ERB syntax error: line 12 ...
```

### Inspect a template’s schema

```bash
render schema ./templates/movie.erb
```

```yaml
name: movie-card
description: Movie details card
schema:
  type: object
  properties:
    title:
      type: string
  required:
    - title
```

### Pipe from other tools

```bash
# Works well with other uncut-gems CLIs
plex library items --section 1 | jq '{title, year}' | render apply ./templates/movie.erb
```

## Exit Codes

### `render apply`

| Code | Meaning |
| --- | --- |
| 0 | Success |
| 1 | Template not found |
| 2 | Invalid JSON input |
| 3 | Validation failed (input doesn’t match schema) |
| 4 | Template rendering error |

### `render validate`

| Code | Meaning |
| --- | --- |
| 0 | Valid |
| 1 | Invalid or error |

### `render check`

| Code | Meaning |
| --- | --- |
| 0 | Template OK |
| 1 | Template has errors |

## Development

```bash
bundle exec rake test      # Run all tests
bundle exec bin/render --help
```
