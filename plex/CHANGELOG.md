# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased][unreleased]

## [1.0.1] - 2026-03-21

### Fixed

- Fixed exit code handling for `movie exists` and `movie watched` commands - they now correctly return exit code 0 when a movie exists/is watched and exit code 1 when not found/not watched
- Fixed error handler in bin/plex to properly propagate SystemExit exceptions instead of treating them as errors

## [1.0.0] - 2026-03-20

### Added

- Initial release of plex CLI gem
- Server information and management commands
- Library browsing and management
- Metadata operations (show, update, children)
- Global search functionality
- Active sessions monitoring
- Watch history tracking
- Playlist management (list, create, edit, delete)
- Collection browsing
- Hub and recommendations access
- Scrobble support (mark played/unplayed)
- DVR and Live TV support
- Account management commands
- Schema introspection command
- JSON/NDJSON output for easy piping to jq
- Automatic MediaContainer envelope unwrapping
- Raw mode flag for full API responses
- Configurable via environment variables or flags

### Documentation

- Comprehensive README with installation, configuration, and usage examples
- MIT License
- Gemspec configured for monorepo distribution via GitHub

[unreleased]: https://github.com/iamveen/uncut-gems/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/iamveen/uncut-gems/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/iamveen/uncut-gems/releases/tag/v1.0.0
