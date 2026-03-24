# Implementation Plan: render gem

A CLI template engine for transforming JSON data into formatted output via ERB
templates.

## Overview

- **Input**: JSON from stdin
- **Output**: Formatted text to stdout (ERB-rendered)
- **Templates**: Files with YAML frontmatter (schema + metadata) and ERB body
- **Validation**: JSON Schema via `json_schemer`

* * *

## CLI Commands

```bash
render apply <template>           # Render stdin JSON through template
render schema <template>          # Show template schema (YAML)
render validate <template>        # Validate input JSON against schema
render check <template>           # Validate the template itself
```

All commands take a direct path to the template file (no discovery/listing).

* * *

## Dependencies

```ruby
spec.add_dependency "gli", "~> 2.21"
spec.add_dependency "json_schemer", "~> 2.0"
# ERB is stdlib
```

Dev dependencies:

```ruby
spec.add_development_dependency "minitest", "~> 5.0"
spec.add_development_dependency "rake", "~> 13.0"
```

* * *

## Directory Structure

```
render/
├── bin/render
├── lib/
│   ├── render.rb
│   └── render/
│       ├── template.rb           # Parse frontmatter + body, render via ERB
│       ├── validator.rb          # json_schemer wrapper
│       ├── template_checker.rb   # Validate template files
│       └── commands/
│           ├── apply.rb
│           ├── schema.rb
│           ├── validate.rb
│           └── check.rb
├── test/
│   ├── test_helper.rb
│   ├── template_test.rb
│   ├── validator_test.rb
│   ├── template_checker_test.rb
│   └── fixtures/
│       ├── valid_template.erb
│       ├── invalid_erb.erb
│       ├── invalid_yaml.erb
│       └── invalid_schema.erb
├── render.gemspec
├── Gemfile
├── Rakefile
├── README.md
└── CHANGELOG.md
```

* * *

## Template File Format

```yaml
---
name: movie-card
description: Movie details card with poster and actions
schema:
  type: object
  properties:
    title:
      type: string
      description: Movie title
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
Year: <%= year %>
<% if cast %>
Cast:
<% cast.each do |actor| %>
  - <%= actor["name"] %><%= " as #{actor["role"]}" if actor["role"] %>
<% end %>
<% end %>
```

* * *

## Exit Codes

| Command | Code | Meaning |
| --- | --- | --- |
| `apply` | 0 | Success |
| `apply` | 1 | Template not found |
| `apply` | 2 | Invalid JSON input |
| `apply` | 3 | Validation failed |
| `apply` | 4 | Render error |
| `validate` | 0 | Valid |
| `validate` | 1 | Invalid |
| `check` | 0 | Template OK |
| `check` | 1 | Template has errors |

* * *

## Class Responsibilities

### `Render::Template`

- Parse YAML frontmatter from template file
- Extract `name`, `description`, `schema`
- Hold ERB body content
- Render with data (returns string)
- Expose schema as Hash

### `Render::Validator`

- Wrap `json_schemer`
- Validate input Hash against schema Hash
- Return `{valid: bool, errors: [...]}`

### `Render::TemplateChecker`

- Check YAML frontmatter syntax
- Check JSON Schema validity
- Check ERB syntax (parse without executing)
- Check required frontmatter fields (`name`, `description`, `schema`)
- Return structured results

* * *

## TDD Approach

**We are following Test-Driven Development.**

### Red-Green-Refactor Cycle

1. **Red**: Write a failing test first
2. **Green**: Write minimal code to make it pass
3. **Refactor**: Clean up while keeping tests green

### Implementation Order

Build bottom-up, testing each layer before moving up:

#### Phase 1: Core Classes (Unit Tests)

1. **`Render::Template`**
   - Test: Parse valid template file
   - Test: Extract frontmatter fields
   - Test: Render with data
   - Test: Handle missing file
   - Test: Handle invalid YAML frontmatter
   - Test: Handle missing frontmatter delimiter

2. **`Render::Validator`**
   - Test: Valid input passes
   - Test: Missing required field fails
   - Test: Wrong type fails
   - Test: Nested object validation
   - Test: Array of objects validation
   - Test: Returns descriptive errors

3. **`Render::TemplateChecker`**
   - Test: Valid template passes all checks
   - Test: Invalid YAML detected
   - Test: Invalid ERB syntax detected
   - Test: Invalid JSON Schema detected
   - Test: Missing required frontmatter fields detected

#### Phase 2: Commands (Integration Tests)

4. **`render apply`**
   - Test: Successful render
   - Test: Template not found (exit 1)
   - Test: Invalid JSON input (exit 2)
   - Test: Validation failure (exit 3)
   - Test: Render error (exit 4)

5. **`render schema`**
   - Test: Outputs YAML schema
   - Test: Template not found

6. **`render validate`**
   - Test: Valid input (exit 0)
   - Test: Invalid input (exit 1, errors to stderr)

7. **`render check`**
   - Test: Valid template (exit 0)
   - Test: Invalid template (exit 1, errors to stderr)

### Test Fixtures

Create fixture templates in `test/fixtures/`:

```yaml
# test/fixtures/simple.erb
---
name: simple
description: Simple test template
schema:
  type: object
  properties:
    title:
      type: string
  required:
    - title
---
Title: <%= title %>
```

```yaml
# test/fixtures/nested.erb
---
name: nested
description: Template with nested data
schema:
  type: object
  properties:
    movie:
      type: object
      properties:
        title:
          type: string
        year:
          type: integer
      required:
        - title
  required:
    - movie
---
<%= movie["title"] %> (<%= movie["year"] %>)
```

```yaml
# test/fixtures/array.erb
---
name: array
description: Template with array
schema:
  type: object
  properties:
    items:
      type: array
      items:
        type: object
        properties:
          name:
            type: string
        required:
          - name
  required:
    - items
---
<% items.each do |item| %>
- <%= item["name"] %>
<% end %>
```

### Running Tests

```bash
cd render
bundle exec rake test
```

* * *

## Implementation Steps

1. [ ] Create gem skeleton (gemspec, Gemfile, Rakefile, lib structure)
2. [ ] Set up test infrastructure (test_helper.rb, fixtures)
3. [ ] TDD `Render::Template`
4. [ ] TDD `Render::Validator`
5. [ ] TDD `Render::TemplateChecker`
6. [ ] TDD `render apply` command
7. [ ] TDD `render schema` command
8. [ ] TDD `render validate` command
9. [ ] TDD `render check` command
10. [ ] Write README with examples
11. [ ] Write CHANGELOG

* * *

## Notes

- Follow patterns from `DESIGN.md` and `AGENTS.md` where applicable
- This gem differs from others: output is formatted text, not JSON
- Errors go to stderr, rendered output to stdout
- Templates use ERB only (no Tilt/multi-engine for now)
- No template discovery/listing - direct paths only
- No nested components/partials for now
