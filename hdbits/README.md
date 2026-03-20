# hdbits

A command-line interface for the HDBits private tracker JSON API.

Outputs raw JSON/NDJSON to stdout for easy piping to `jq` and other Unix tools.

## Installation

Add to your Gemfile (requires Bundler 2.3+):

```ruby
gem "hdbits", github: "yourusername/uncut-gems", subdir: "hdbits"
```

Then run:

```bash
bundle install
```

### From Source

```bash
git clone https://github.com/yourusername/uncut-gems.git
cd uncut-gems/hdbits
bundle install
bundle exec bin/hdbits --help
```

## Configuration

Set your HDBits credentials via environment variables:

```bash
export HDBITS_USERNAME="your_username"
export HDBITS_PASSKEY="your_passkey"  # from your announce URL
```

Or pass them as flags:

```bash
hdbits --username your_username --passkey your_passkey <command>
```

## Usage

```bash
hdbits --help
hdbits <command> --help
```

### Commands

| Command | Description |
| --- | --- |
| `test` | Test authentication credentials |
| `user` | Return info about the authenticated user |
| `tags` | List all tags defined on the site |
| `torrent list` | Search/browse torrents |
| `torrent info` | Get details for a specific torrent |
| `top films` | Top 50 films for a given time period |
| `top tv` | Top 50 TV shows for a given time period |
| `wishlist list` | Return the user’s wishlist |
| `wishlist add` | Add a film to the wishlist by IMDb ID |
| `wishlist del` | Remove an item from the wishlist |
| `subtitles` | Return subtitles linked to a torrent |
| `rss-add` | Add a torrent to personal RSS feed |
| `schema` | Show the output schema for a command |

### Examples

```bash
# Test credentials
hdbits test

# Search for torrents
hdbits torrent list --search "The Matrix" --limit 10

# Get user info, extract specific fields with jq
hdbits user | jq '{username, ratio, uploaded, downloaded}'

# List top films this week as NDJSON, filter with jq
hdbits top films --list FilmNewThisWeek | jq 'select(.seeders > 10)'

# Get all tags
hdbits tags

# View schema for a command
hdbits schema "torrent list"
```

### Logging

```bash
# Enable debug logging to stderr
hdbits --log-level debug torrent list --search "test"

# Log to a file
hdbits --log-output /tmp/hdbits.log --log-level info torrent list
```

## Output Format

- **Single objects** are output as pretty-printed JSON
- **Lists** are output as NDJSON (one JSON object per line) for easy streaming and
  processing with `jq`
- Use `--raw` flag (where available) to get the full API envelope

## Development

```bash
bundle install
bundle exec bin/hdbits --help
```

## License

MIT License. See [LICENSE](LICENSE) for details.
