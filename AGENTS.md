# AGENTS.md

This document provides AI agents with essential context for working on the Uncut Gems
repository.

## Required Reading

**Before making any architectural decisions or adding features, read `DESIGN.md`.**

The DESIGN.md file contains the complete design philosophy and patterns that all gems in
this repository must follow.
It covers output formats, filtering strategies, naming conventions, schema
introspection, and more.

**When to read DESIGN.md:**
- Before adding new commands
- Before changing output formats
- Before creating new gems
- When deciding between CLI flags vs.
  jq filtering
- When implementing envelope unwrapping
- When adding schema definitions

## Project Overview

**Uncut Gems** is a monorepo containing independent Ruby gems that provide composable
CLI wrappers around JSON APIs for media management tools and services.

### Core Philosophy

- **Composability**: All CLIs output JSON/NDJSON for easy piping to `jq` and Unix tools
- **LLM-friendly**: Designed for automation, scripting, and agent use
- **Schema introspection**: Built-in schema commands for discoverability
- **Minimal dependencies**: Primarily Faraday (HTTP client) and GLI (CLI framework)
- **Design consistency**: All gems follow the patterns in `DESIGN.md`

## Repository Structure

```
uncut-gems/
├── README.md           # Main repository documentation
├── AGENTS.md          # This file
├── hdbits/            # HDBits API wrapper
│   ├── bin/hdbits
│   ├── lib/hdbits/
│   │   ├── client.rb      # Faraday-based API client
│   │   ├── output.rb      # JSON/NDJSON output formatter
│   │   ├── logger.rb      # Debug logging
│   │   └── commands/      # GLI command definitions
│   ├── hdbits.gemspec
│   ├── Gemfile
│   ├── README.md
│   └── CHANGELOG.md
├── plex/              # Plex Media Server API wrapper
│   ├── bin/plex
│   ├── lib/plex/
│   │   ├── client.rb      # Faraday-based API client
│   │   ├── output.rb      # JSON/NDJSON output formatter
│   │   ├── schema.rb      # Schema introspection
│   │   ├── guid_helper.rb # GUID parsing utilities
│   │   └── commands/      # GLI command definitions
│   ├── plex.gemspec
│   ├── Gemfile
│   ├── README.md
│   └── CHANGELOG.md
├── qbit/              # qBittorrent Web API wrapper
├── radarr/            # Radarr API wrapper
└── sonarr/            # Sonarr API wrapper
```

### Gem Independence

Each gem is **fully self-contained** with:
- Its own `Gemfile` and dependencies
- Its own executable in `bin/`
- Its own `README.md` and `CHANGELOG.md`
- Its own version number (defined in `lib/<gem>/<gem>.rb`)
- No cross-gem dependencies

## Design Philosophy

**All gems follow the design principles documented in `DESIGN.md`.**

**Quick summary** (read DESIGN.md for complete details):
- Output raw JSON/NDJSON to stdout
- Use stderr for errors and logging
- Unwrap API envelopes by default (`--raw` flag to preserve)
- Support schema introspection via `schema` command
- Consistent flag naming across gems
- Defensive limits with `--limit` and `--all` flags
- Client-side filtering when API lacks support
- Human-readable flag values over integer codes

## Architecture Overview

Each gem follows a standard structure:

### 1. Client Class (`lib/<gem>/client.rb`)

- HTTP communication via Faraday
- Authentication (API keys, tokens, session cookies)
- Error handling

### 2. Output Module (`lib/<gem>/output.rb`)

- Format responses as JSON or NDJSON
- Unwrap API envelopes
- Handle `--raw` flag

### 3. Commands (`lib/<gem>/commands/`)

- Each command domain in its own file
- Built with GLI DSL
- Register with main executable

### 4. Schema Module (`lib/<gem>/schema.rb`)

- Maps commands to output schemas
- Enables `<gem> schema "command name"`

### 5. Main Executable (`bin/<gem>`)

- GLI-based CLI definition
- Global flags (`--url`, `--token`, `--verbose`)
- Loads and registers commands

## Development Workflow

### Working on a Specific Gem

```bash
cd <gem-name>
bundle install
bundle exec bin/<gem-name> --help
```

### Adding a New Command

1. Create or edit a file in `lib/<gem>/commands/`
2. Define the command using GLI DSL
3. Implement the action block
4. Test with `bundle exec bin/<gem-name> <command>`
5. Update the gem’s README.md with usage examples
6. **Increment version** in `lib/<gem>/<gem>.rb` (typically MINOR version for new
   commands)
7. Add an entry to CHANGELOG.md under the new version
8. Commit with message: `<gem>: bump to vX.Y.Z - add <command> command`

### Adding a New Gem

1. Create a new directory: `<gem-name>/`
2. Create standard files:
   - `<gem-name>.gemspec` (follow existing patterns)
   - `Gemfile` (source gemspec)
   - `lib/<gem-name>.rb` (main entrypoint)
   - `lib/<gem-name>/version.rb`
   - `lib/<gem-name>/client.rb`
   - `lib/<gem-name>/output.rb`
   - `lib/<gem-name>/commands/`
   - `bin/<gem-name>` (executable)
   - `README.md`
   - `CHANGELOG.md`
3. Add to the table in the main `README.md`

### Versioning and Releases

**CRITICAL: Always increment the version number before committing changes to a gem.**

#### Version Number Location

Each gem’s version is defined as a constant in its main module file:
- **Location**: `lib/<gem>/<gem>.rb`
- **Format**: `VERSION = "MAJOR.MINOR.PATCH"`
- **Example**: `module Plex; VERSION = "1.2.3"; end`

#### Semantic Versioning Rules

Follow [Semantic Versioning 2.0.0](https://semver.org/):

**MAJOR version (x.0.0)** - Increment when you make incompatible API changes:
- Breaking changes to command names or flag behavior
- Removing commands or flags
- Changing output format in a non-backward-compatible way
- Changing authentication mechanisms

**MINOR version (0.x.0)** - Increment when you add functionality in a
backward-compatible manner:
- Adding new commands
- Adding new flags to existing commands (with sensible defaults)
- Adding new output fields (JSON keys)
- Implementing new API endpoints
- Adding schema introspection

**PATCH version (0.0.x)** - Increment when you make backward-compatible bug fixes:
- Fixing bugs in existing commands
- Correcting output formatting issues
- Fixing authentication or session handling
- Improving error messages
- Documentation-only changes
- Performance improvements

#### Version Bump Decision Tree

```
Is the change breaking existing behavior?
├─ YES → Bump MAJOR version (e.g., 1.2.3 → 2.0.0)
└─ NO
   ├─ Does it add new functionality?
   │  ├─ YES → Bump MINOR version (e.g., 1.2.3 → 1.3.0)
   │  └─ NO → Bump PATCH version (e.g., 1.2.3 → 1.2.4)
   └─ Is it a bug fix or docs-only change?
      └─ YES → Bump PATCH version (e.g., 1.2.3 → 1.2.4)
```

#### Pre-Commit Checklist

Before committing changes to a gem:

1. **Update the version number** in `lib/<gem>/<gem>.rb`:
   ```ruby
   module Plex
     VERSION = "1.3.0"  # Was "1.2.3"
   end
   ```

2. **Update CHANGELOG.md** with an entry for the new version:
   ```markdown
   ## [1.3.0] - 2026-03-20

   ### Added
   - New `library scan` command for triggering library scans
   - Schema introspection support via `plex schema "command"`

   ### Fixed
   - Authentication error handling now provides clearer messages
   ```

3. **Test the changes**:
   ```bash
   bundle exec bin/<gem> --version  # Verify version number
   bundle exec bin/<gem> <command>  # Test functionality
   ```

4. **Commit with a descriptive message**:
   ```bash
   git add lib/<gem>/<gem>.rb <gem>/CHANGELOG.md <other-files>
   git commit -m "<gem>: bump to v1.3.0 - add library scan command"
   ```

#### CHANGELOG.md Format

Use this structure for changelog entries:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Features planned but not yet released

## [1.3.0] - 2026-03-20

### Added
- New commands or features

### Changed
- Changes to existing functionality

### Fixed
- Bug fixes

### Removed
- Removed features or commands
```

**Group changes by type**: Added, Changed, Deprecated, Removed, Fixed, Security

#### Common Versioning Scenarios

| Change Type | Example | Version Bump |
| --- | --- | --- |
| Add new command | `plex library scan` | MINOR (1.2.3 → 1.3.0) |
| Add new flag (optional) | `--format` flag | MINOR (1.2.3 → 1.3.0) |
| Fix output formatting | Correct JSON structure | PATCH (1.2.3 → 1.2.4) |
| Fix authentication bug | Session handling | PATCH (1.2.3 → 1.2.4) |
| Rename command | `list` → `show` | MAJOR (1.2.3 → 2.0.0) |
| Change required flag | Make `--id` required | MAJOR (1.2.3 → 2.0.0) |
| Remove command | Delete `old-cmd` | MAJOR (1.2.3 → 2.0.0) |
| Update README only | Documentation | PATCH (1.2.3 → 1.2.4) |
| Add schema support | Schema introspection | MINOR (1.2.3 → 1.3.0) |

### Testing Changes

Since this is a CLI tool collection, testing is primarily manual:
```bash
bundle exec bin/<gem> <command> [flags] | jq
```

Consider:
- Testing with and without `--raw` flag
- Piping to `jq` for filtering
- Testing error cases (missing auth, invalid IDs, etc.)
- Testing with `--verbose` for debugging
- Verifying version number with `--version` flag

## Important Conventions

### Environment Variables

Gems use environment variables for configuration:
- `PLEX_URL` and `PLEX_TOKEN` (plex)
- `HDBITS_USERNAME` and `HDBITS_PASSKEY` (hdbits)
- `QBIT_URL`, `QBIT_USERNAME`, `QBIT_PASSWORD` (qbit)

These can be overridden with CLI flags (`--url`, `--token`, etc.).

### Logging and Debugging

- Use `--verbose` flag to enable debug logging
- Log HTTP requests and responses in client classes
- Redact sensitive data (tokens, passkeys) in logs

### Error Handling

- Let Faraday exceptions bubble up (GLI will catch and format)
- Return meaningful error messages for common issues (missing auth, not found, etc.)
- Use HTTP status codes to determine error types

### Versioning

- **Each gem has its own independent version** (never increment versions across gems)
- **Always increment version before committing** (see “Versioning and Releases” section)
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update both `lib/<gem>/<gem>.rb` and `CHANGELOG.md` together
- Version format: `VERSION = "1.2.3"` in `lib/<gem>/<gem>.rb`

### Output Format Rules

**CRITICAL:**
- Single objects → Pretty JSON
- Arrays → NDJSON (one object per line)
- Unwrap API envelopes by default
- Provide `--raw` flag to preserve envelopes
- Never mix output formats in a single command
- Write data to stdout, logs to stderr

## Common Tasks

### Finding API Endpoints

- Check the API documentation for the service
- Use browser dev tools to inspect network requests
- Enable `--verbose` to see actual requests made

### Adding Pagination

Standard pattern (see `DESIGN.md` for details):
```ruby
cmd.flag [:l, :limit], type: Integer, default_value: 50
cmd.flag [:o, :offset], type: Integer, default_value: 0
cmd.switch :all, desc: "Remove limit", negatable: false
```

### Adding Schema Introspection

See `plex/lib/plex/schema.rb` for a complete implementation.
Consult `DESIGN.md` for schema format guidelines.

### Handling File Uploads

See `qbit/lib/qbit/client.rb` for multipart form example.

## Tools and Dependencies

### Core Dependencies

- **Faraday** (~> 2.0): HTTP client
- **GLI** (~> 2.21): CLI framework
- **Ruby** (>= 2.7.0)

### Development Tools

- **bundler** (~> 2.0): Dependency management
- **rake** (~> 13.0): Build automation
- **jq**: JSON processing (external, used for testing)

### Installation from Monorepo

Bundler 2.3+ supports git sources with subdirectories:
```ruby
gem "plex", github: "iamveen/uncut-gems", subdir: "plex"
```

## Design Patterns

All gems in this repository follow the design principles documented in **`DESIGN.md`**.

**Key principles:**
- Output raw JSON/NDJSON to stdout
- NDJSON for arrays (streaming-friendly)
- Unwrap API envelopes by default
- Schema introspection via `<gem> schema` command
- Design for piping to `jq`
- Consistent flag naming across gems
- Client-side filtering when API lacks support

**Action required: Read `DESIGN.md` before:**
- Adding new commands (to understand output format rules)
- Changing output formats (to follow NDJSON vs JSON guidelines)
- Creating new gems (to use the standard structure)
- Making architectural decisions (to maintain consistency)
- Implementing filtering (to decide flags vs jq)
- Adding schema definitions (to follow the schema format)

## Documentation Standards

### README.md (per gem)

Must include:
- Installation instructions
- Configuration (env vars, flags)
- Command table with descriptions
- Usage examples (basic and with `jq`)
- Output format explanation
- Link to main repo

### CHANGELOG.md (per gem)

- One entry per version
- Group changes by type (Added, Changed, Fixed, Removed)
- Include dates in YYYY-MM-DD format

## Common Pitfalls

1. **Not following DESIGN.md**: Read it before making architectural decisions
2. **Mixing output formats**: Don’t output both JSON and NDJSON in the same command
3. **Writing to stdout instead of stderr**: Logs and errors go to stderr
4. **Not redacting secrets**: Always redact tokens/passkeys in debug logs
5. **Ignoring envelope unwrapping**: Users expect clean data, not wrapped responses
6. **Inconsistent flag naming**: Use standard flag names documented in DESIGN.md
7. **Forgetting schema updates**: When adding commands, update schema definitions
8. **Breaking gem independence**: Don’t add cross-gem dependencies
9. **Forgetting to version bump**: Always increment version before committing

## Getting Help

- Check the gem’s README.md for usage examples
- Use `--help` flag on any command
- Use `--verbose` to debug HTTP requests
- Check API documentation for the service
- Review existing commands for patterns

## Quick Reference

```bash
# Work on a gem
cd plex && bundle install

# Test a command
bundle exec bin/plex server info

# Check version
bundle exec bin/plex --version

# Test with jq
bundle exec bin/plex library list | jq -r '.title'

# Debug mode
bundle exec bin/plex --verbose server info

# Check schema
bundle exec bin/plex schema "library list"

# Before committing: bump version
# 1. Edit lib/plex/plex.rb - change VERSION = "1.2.3" to "1.3.0"
# 2. Update CHANGELOG.md with changes
# 3. Test: bundle exec bin/plex --version
# 4. Commit: git commit -m "plex: bump to v1.3.0 - add new feature"

# Install gem from monorepo
# In another project's Gemfile:
gem "plex", github: "iamveen/uncut-gems", subdir: "plex"
```

* * *

**Last Updated**: 2026-03-20
