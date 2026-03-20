# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased][unreleased]

## [1.0.0] - 2026-03-20

### Added

- Initial release of qbit CLI gem
- Torrent management commands (list, get, add, pause, resume, delete, etc.)
- Torrent control operations (recheck, reannounce, rename, move)
- Torrent configuration (categories, tags, speed limits, share limits)
- File and tracker inspection per torrent
- Peer listing for torrents
- Category management (list, create, edit, delete)
- Tag management (list, create, delete)
- Transfer info and global speed limit controls
- Application info, preferences, and session management
- Schema introspection command
- JSON/NDJSON output for easy piping to jq
- Automatic session management with persistent cookie storage
- Multipart file upload support for .torrent files
- Configurable via environment variables or flags
- Batch operations with comma-separated hash lists
- Special “all” keyword for hash parameters

### Documentation

- Comprehensive README with installation, configuration, and usage examples
- MIT License
- Gemspec configured for monorepo distribution via GitHub

[unreleased]: https://github.com/iamveen/uncut-gems/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/iamveen/uncut-gems/releases/tag/v1.0.0
