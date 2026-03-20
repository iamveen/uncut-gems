# CLI Design Guide

Design principles and patterns for building composable CLI wrappers around JSON APIs,
optimized for use with LLM agents and Unix pipelines.

All gems in this repository follow these guidelines.

* * *

## Core Philosophy

These CLIs are designed for:
- **Composability**: Pipe-friendly output for use with `jq`, `xargs`, and other Unix
  tools
- **LLM agents**: Self-documenting with schema introspection
- **Automation**: Consistent patterns across all gems

* * *

## Technology Stack

- **Ruby + GLI**: Multi-command CLI framework
- **Faraday**: HTTP client (handles auth, retries, middleware cleanly)
- **jq**: Consumer-side response shaping and post-processing

* * *

## Output Format

### Golden Rule: Raw JSON to stdout

**Always write raw JSON to stdout.
No exceptions.**

Your wrapper’s job is to get clean JSON out of the API. Reshaping, field selection, and
filtering the response are the consumer’s responsibility - do it with `jq`.

```bash
plex library list | jq '.title'
plex library list | jq '{title, year, type}'
```

### Everything Else to stderr

Write errors, warnings, progress indicators, and debug logs to stderr.
This keeps stdout clean for piping.

```ruby
$stderr.puts "Error: #{e.message}"
exit 1
```

### Exit Codes Matter

Use `0` for success, non-zero for failure.
This is how shell scripts and LLM agents detect failures without parsing output.

### Lists: Use NDJSON

For endpoints that return lists, output **one JSON object per line** (NDJSON) rather
than a JSON array. NDJSON plays much better with `xargs`, `parallel`, and streaming -
JSON arrays must be fully buffered before `jq` can process them.

```
# Prefer this (NDJSON)
{"id": 1, "title": "Movie A"}
{"id": 2, "title": "Movie B"}

# Over this (JSON array)
[{"id": 1, "title": "Movie A"}, {"id": 2, "title": "Movie B"}]
```

### Single Objects: Pretty JSON

For commands that return a single object, use pretty-printed JSON:

```json
{
  "id": 123,
  "title": "Movie Title",
  "year": 2024
}
```

* * *

## Input and Filtering

### The Core Principle

> If the filter reduces data *fetched*, it’s a CLI flag.
> If it reduces data *returned*, it’s `jq`.

| Filter Type | Where It Lives |
| --- | --- |
| API query params (search, date range, status) | CLI flag |
| Pagination | CLI flag |
| Field selection / reshaping | `jq` |
| Response filtering | `jq` |

**Examples:**

```bash
# API-level filter - must be a flag (controls what leaves the server)
plex library items --section 1 --limit 50

# Post-processing - just use jq (controls what you display)
plex library items --section 1 | jq 'select(.year > 2020)'
```

### Client-Side Filtering and Sorting

When an API doesn’t support a filter or sort that users commonly need, implement it
client-side in Ruby rather than forcing users to write complex `jq` for every
invocation.

```ruby
# Client-side quality filtering (API doesn't support resolution filter)
if opts[:quality]
  patterns = parse_quality_patterns(opts[:quality])
  body["data"] = body["data"].select do |t|
    patterns.any? { |pat| t["name"].to_s.include?(pat) }
  end
end

# Client-side sorting (API sorting unreliable)
if opts[:sort]
  body["data"] = sort_results(body["data"], opts[:sort], opts[:order])
end
```

**Document client-side filters clearly:**

```ruby
c.flag :quality, desc: "Comma-sep resolutions (client-side): 2160p, 1080p, 720p"
c.flag :sort,    desc: "Comma-sep sort (client-side): name, size, seeders"
```

### Human-Readable Flag Values

When APIs use integer codes, map human-readable strings to those codes:

```ruby
CODEC_MAP = {
  "h264" => 1,
  "hevc" => 5,
  "mpeg2" => 2,
  "vc1" => 3,
  "xvid" => 4
}.freeze

def self.parse_codec_list(str)
  str.to_s.split(",").map do |c|
    CODEC_MAP[c.strip.downcase] || raise("Unknown codec: #{c}")
  end
end
```

```bash
# Human-readable (preferred)
hdbits search --codec=hevc,h264

# Instead of raw integers
hdbits search --codec=5,1
```

### Multi-Value Flags (OR Filtering)

Support comma-separated values for OR filtering:

```bash
hdbits search --quality=2160p,1080p --codec=hevc,h264
```

Parse with:

```ruby
str.to_s.split(",").map(&:strip)
```

### Defensive Limits

When datasets can be large, add a `--limit` flag with a conservative default.
Require an explicit `--all` flag to remove the cap.
This protects against accidentally pulling large datasets in automated/agent contexts.

```bash
plex history                 # Returns up to 50 by default
plex history --all           # Explicit opt-in to full dataset
plex history --limit 10      # Custom limit
```

```ruby
c.flag :limit, type: Integer, default_value: 50, desc: "Max results (use --all for unlimited)"
c.switch :all, desc: "Remove record limit", negatable: false
```

* * *

## Response Envelope Unwrapping

If the API wraps responses in an envelope (`{"MediaContainer": {...}}`,
`{"data": [...], "meta": {...}}`), unwrap to just the data by default.
Provide a `--raw` flag to return the full envelope when needed.

```bash
plex library list         # Returns the array directly
plex library list --raw   # Returns full {"MediaContainer": {...}}
```

**Implementation pattern:**

```ruby
def self.format(data, raw: false)
  # Unwrap common envelope patterns
  unless raw
    data = data["MediaContainer"] if data.is_a?(Hash) && data.key?("MediaContainer")
    data = data["data"] if data.is_a?(Hash) && data.key?("data")
  end

  # Output as JSON or NDJSON
  if data.is_a?(Array)
    ndjson(data)
  else
    pretty(data)
  end
end
```

* * *

## Naming Conventions

Use **consistent flag names** across all gems in this repository.
LLMs compose these tools together - inconsistent naming causes mistakes.

**Standard flag names:**

| Flag | Purpose | Type |
| --- | --- | --- |
| `--limit` | Maximum records to return | Integer |
| `--offset` | Pagination offset | Integer |
| `--all` | Remove default limit | Switch |
| `--raw` | Return full API envelope | Switch |
| `--section` | Library section ID | Integer |
| `--key` | Item key/ID | String/Integer |
| `--query` | Search query | String |
| `--since` | Date filter (after) | String (ISO8601) |
| `--until` | Date filter (before) | String (ISO8601) |

**Consistency rules:**
- Use `--user-id` everywhere, not `--user` in one place and `--uid` in another
- Use the same entity names your API uses internally
- Keep command names as close to the API endpoint semantics as possible

* * *

## Schema Introspection

Every gem should expose a `schema` command so LLMs can inspect output structures at
runtime. No separate documentation to maintain or drift out of sync.

```bash
plex schema "library list"    # Output structure for a specific command
plex schema                    # Lists all commands and their schemas
```

### Schema Format

Schema output is lightweight JSON - not full JSON Schema, just enough for an LLM to
write confident `jq` filters:

```json
{
  "output": "ndjson",
  "record": {
    "id": { "type": "integer" },
    "title": { "type": "string" },
    "year": { "type": "integer" },
    "type": { "type": "string", "enum": ["movie", "show", "artist"] },
    "addedAt": { "type": "integer", "format": "unix_timestamp" }
  }
}
```

For single-object responses, use `"output": "json"` instead of `"ndjson"`.

### Implementation Pattern

See `plex/lib/plex/schema.rb` for a full implementation.

**Basic structure:**

```ruby
module YourGem
  SCHEMAS = {
    "library list" => {
      output: "ndjson",
      record: {
        title: { type: "string" },
        key: { type: "string" },
        type: { type: "string", enum: ["movie", "show", "artist"] }
      }
    }
  }.freeze

  def self.schema_for(command_name)
    SCHEMAS[command_name]
  end
end
```

**In the main executable:**

```ruby
desc "Show output schema for a command"
arg :command_name, :optional
command :schema do |c|
  c.action do |_global, _options, args|
    if args.empty?
      puts JSON.pretty_generate(YourGem::SCHEMAS)
    else
      schema = YourGem::SCHEMAS[args.first]
      if schema
        puts JSON.pretty_generate(schema)
      else
        $stderr.puts "Unknown schema: #{args.first}"
        exit 1
      end
    end
  end
end
```

* * *

## GLI Patterns

### Argument Order

GLI requires flags **before** positional arguments:

```bash
# Correct
plex search --limit=10 "query string"

# Wrong - GLI will error
plex search "query string" --limit=10
```

### Shared Flag Helpers

For commands with overlapping flags, extract shared helpers:

```ruby
def self.add_pagination_flags(c)
  c.flag :limit, type: Integer, default_value: 50, desc: "Max results"
  c.flag :offset, type: Integer, default_value: 0, desc: "Offset for pagination"
  c.switch :all, desc: "Remove limit", negatable: false
end

def self.add_output_flags(c)
  c.switch :raw, desc: "Return full API envelope", negatable: false
end
```

**Usage:**

```ruby
c.command :list do |cmd|
  add_pagination_flags(cmd)
  add_output_flags(cmd)

  cmd.action do |global, options, args|
    # ...
  end
end
```

### Command Registration Pattern

Each command group lives in its own file and registers itself:

```ruby
# lib/gem/commands/library.rb
module YourGem
  module Commands
    def self.register_library(prog)
      prog.desc "Library operations"
      prog.command :library do |c|
        c.desc "List libraries"
        c.command :list do |list|
          list.action do |global, options, args|
            # Implementation
          end
        end
      end
    end
  end
end
```

**In main executable:**

```ruby
require_relative "lib/your_gem/commands/library"

YourGem::Commands.register_library(self)
```

This keeps the executable clean and makes commands independently testable.

* * *

## Ruby Gem Structure

### Directory Layout

```
gem-name/
├── bin/
│   └── gem-name              # Executable (#!/usr/bin/env ruby)
├── lib/
│   ├── gem_name.rb           # Main module (VERSION + requires)
│   └── gem_name/
│       ├── client.rb         # HTTP client (Faraday)
│       ├── output.rb         # JSON/NDJSON formatting
│       ├── schema.rb         # Output schema definitions (optional)
│       └── commands/         # Command modules
│           ├── server.rb
│           ├── library.rb
│           └── search.rb
├── gem-name.gemspec          # Gem specification
├── Gemfile                   # Points to gemspec
├── README.md
├── CHANGELOG.md
└── LICENSE
```

### Main Module (`lib/gem_name.rb`)

```ruby
# frozen_string_literal: true

require "faraday"
require "json"

module GemName
  VERSION = "1.0.0"
end

require_relative "gem_name/client"
require_relative "gem_name/output"
require_relative "gem_name/schema"
require_relative "gem_name/commands/server"
require_relative "gem_name/commands/library"
```

Keep this file minimal - just the VERSION constant and `require_relative` statements.

### Client Class (`lib/gem_name/client.rb`)

```ruby
require "faraday"
require "json"

module GemName
  class Client
    BASE_URL = "https://api.example.com"

    def initialize(url:, token:)
      @url = url
      @token = token
      @conn = Faraday.new(url: url) do |f|
        f.headers["X-Auth-Token"] = token
        f.headers["Accept"] = "application/json"
        f.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      response = @conn.get(path, params)
      handle_response(response)
    end

    private

    def handle_response(response)
      unless response.success?
        $stderr.puts "HTTP #{response.status}: #{response.body}"
        exit 1
      end
      JSON.parse(response.body)
    end
  end
end
```

### Output Module (`lib/gem_name/output.rb`)

```ruby
require "json"

module GemName
  module Output
    def self.format(data, raw: false)
      # Unwrap envelopes unless --raw
      unless raw
        data = unwrap(data)
      end

      # Output as JSON or NDJSON
      if data.is_a?(Array)
        ndjson(data)
      else
        pretty(data)
      end
    end

    def self.pretty(obj)
      puts JSON.pretty_generate(obj)
    end

    def self.ndjson(array)
      array.each { |item| puts JSON.generate(item) }
    end

    def self.unwrap(data)
      # Unwrap common envelope patterns
      data = data["MediaContainer"] if data.is_a?(Hash) && data.key?("MediaContainer")
      data = data["data"] if data.is_a?(Hash) && data.key?("data")
      data
    end
  end
end
```

### Main Executable (`bin/gem-name`)

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "gli"
require "gem_name"

include GLI::App

program_desc "CLI wrapper for ExampleAPI. Outputs raw JSON/NDJSON to stdout."
version GemName::VERSION

subcommand_option_handling :normal
arguments :strict

# Global flags
desc "API URL (overrides EXAMPLE_URL env var)"
flag :url

desc "API token (overrides EXAMPLE_TOKEN env var)"
flag :token

desc "Enable debug logging"
switch :verbose

# Pre-command setup
pre do |global, _command, _options, _args|
  url = global[:url] || ENV["EXAMPLE_URL"]
  token = global[:token] || ENV["EXAMPLE_TOKEN"]

  unless url && token
    $stderr.puts "Error: URL and token required"
    exit 1
  end

  global[:client] = GemName::Client.new(url: url, token: token)
  true
end

# Error handler
on_error do |e|
  $stderr.puts "Error: #{e.message}"
  false
end

# Register commands
GemName::Commands.register_server(self)
GemName::Commands.register_library(self)

exit run(ARGV)
```

* * *

## Help Documentation = Skill Files

GLI auto-generates `--help` output from your command definitions.
Write your `desc` strings as if they are the skill file - **because they are**.

```ruby
desc "Fetch orders for a user. Returns NDJSON, one order per line."
command :get_orders do |c|
  c.flag :user_id, required: true, desc: "User ID to fetch orders for"
  c.flag :since, desc: "ISO8601 date - only return orders after this"
  c.flag :limit, type: Integer, desc: "Max records (default: 100). Use --all for no limit."
  c.switch :all, desc: "Remove the default record limit"
  c.switch :raw, desc: "Return full API envelope instead of unwrapped data"

  c.action do |global, options, args|
    # Implementation
  end
end
```

The auto-generated `--help` output is what LLMs read to understand how to use your tool.
**Invest in good descriptions.**

* * *

## Installation Patterns

### From Source

```bash
git clone https://github.com/yourname/uncut-gems.git
cd uncut-gems/gem-name
bundle install
bundle exec bin/gem-name --help
```

### From GitHub (Bundler 2.3+)

```ruby
# Gemfile
gem "gem-name", github: "yourname/uncut-gems", subdir: "gem-name"
```

Then `bundle install`.

### Build and Install Locally

```bash
cd gem-name
gem build gem-name.gemspec
gem install ./gem-name-*.gem
rm ./gem-name-*.gem
```

* * *

## Summary Table

| Concern | Decision |
| --- | --- |
| Output format | Raw JSON to stdout |
| Lists | NDJSON (one object per line) |
| Single objects | Pretty-printed JSON |
| Field selection | Consumer’s job (`jq`) |
| Response filtering | Consumer’s job (`jq`), or client-side for common filters |
| API-level filtering | CLI flags |
| Client-side filtering | OK when API lacks support; document as “(client-side)” |
| Client-side sorting | OK when API sorting is unreliable |
| Human-readable flags | Map strings to API integer codes |
| Multi-value flags | Comma-separated for OR filtering |
| Large datasets | `--limit` with safe default + `--all` opt-in |
| Envelope unwrapping | Unwrap by default, `--raw` flag for envelope |
| Non-data output | stderr only |
| Errors | stderr + non-zero exit code |
| Naming | Consistent flag names across all gems |
| Documentation | GLI `desc` strings = self-documenting |
| Output schemas | `gem-name schema <command>` — discoverable at runtime |
| GLI argument order | Flags before positional arguments |

* * *

**See also:**
- `AGENTS.md` - Practical workflows for working on this repository
- Individual gem READMEs - Usage examples and API-specific details
