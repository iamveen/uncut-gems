# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-24

### Added

- `render apply <template>` - render stdin JSON through an ERB template
- `render schema <template>` - output template schema as YAML
- `render validate <template>` - validate stdin JSON against template schema
- `render check <template>` - validate template file (YAML, ERB syntax, JSON Schema,
  required fields)
- ERB templates with YAML frontmatter (`name`, `description`, `schema`)
- JSON Schema validation via `json_schemer`
- Support for nested objects and arrays in schemas
- Exit codes for all error conditions
