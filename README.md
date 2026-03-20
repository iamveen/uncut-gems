# Uncut Gems

A monorepo of Ruby gems and CLI tools.

## What’s Inside

This repository contains a collection of independent Ruby gems, each providing
command-line interfaces and API client libraries:

| Gem | Description |
| --- | --- |
| [hdbits](hdbits/) | CLI wrapper for the HDBits API |
| [plex](plex/) | CLI wrapper for the Plex API |
| [qbit](qbit/) | CLI wrapper for the qBittorrent Web API |
| [radarr](radarr/) | CLI wrapper for the Radarr API |
| [sonarr](sonarr/) | CLI wrapper for the Sonarr API |

Each gem is designed with composability in mind:
- Outputs JSON/NDJSON for easy piping to `jq` and other Unix tools
- Built with Faraday and GLI
- Includes schema introspection for discoverability

## Installation

Each gem can be installed independently via Bundler 2.3+ (git sources with
subdirectories):

```ruby
# Gemfile
gem "plex", github: "iamveen/uncut-gems", subdir: "plex"
gem "qbit", github: "iamveen/uncut-gems", subdir: "qbit"
```

Then run:

```bash
bundle install
```

## Usage

Each gem has its own README with detailed usage instructions:

```bash
# Example
cd plex
bundle install
bundle exec bin/plex --help
```

## Development

Each gem is self-contained with its own dependencies:

```bash
cd <gem-name>
bundle install
bundle exec bin/<gem-name> --help
```

## License

MIT License. See individual gem directories for details.
