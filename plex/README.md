# plex

A command-line interface for the Plex Media Server JSON API.

Outputs raw JSON/NDJSON to stdout for easy piping to `jq` and other Unix tools.

## Installation

Add to your Gemfile (requires Bundler 2.3+):

```ruby
gem "plex", github: "iamveen/uncut-gems", subdir: "plex"
```

Then run:

```bash
bundle install
```

### From Source

```bash
git clone https://github.com/iamveen/uncut-gems.git
cd uncut-gems/plex
bundle install
bundle exec bin/plex --help
```

## Configuration

Set your Plex server URL and authentication token via environment variables:

```bash
export PLEX_URL="http://192.168.1.10:32400"
export PLEX_TOKEN="your_token_here"
```

Or pass them as flags:

```bash
plex --url http://192.168.1.10:32400 --token your_token_here <command>
```

### Finding Your Token

1. Open Plex Web App
2. Play any media item
3. Click the ⋮ menu → “Get Info”
4. Click “View XML”
5. Look for `X-Plex-Token` in the URL

## Usage

```bash
plex --help
plex <command> --help
```

### Commands

| Command | Description |
| --- | --- |
| `server info` | Server identity and feature flags |
| `server prefs` | Read or write server-level preferences |
| `server activities` | Background activities (transcoding, scans, etc.) |
| `server butler` | Butler tasks (library maintenance, backups, etc.) |
| `server updater` | Check for and manage server updates |
| `library list` | List all library sections |
| `library items` | Show items in a library section |
| `library recent` | Recently added items |
| `library scan` | Trigger a library scan |
| `library refresh` | Refresh library metadata |
| `metadata show` | Get metadata for a specific item |
| `metadata children` | Get children (e.g., episodes of a TV show) |
| `search` | Global search across all libraries |
| `sessions list` | Active playback sessions |
| `sessions kill` | Terminate a playback session |
| `history` | Watch history with filtering and pagination |
| `playlists list` | List all playlists |
| `playlists items` | Show playlist items |
| `playlists create` | Create a new playlist |
| `collections list` | List collections in a library |
| `collections items` | Show collection items |
| `hubs` | Home screen hubs and recommendations |
| `scrobble` | Mark items as played/unplayed |
| `dvr` | DVR configurations and Live TV guide |
| `accounts` | Managed users and account info |
| `schema` | Show the output schema for a command |

### Examples

```bash
# Server information
plex server info

# Search across all libraries
plex search --query "Star Wars"

# List libraries, extract just names with jq
plex library list | jq -r '.title'

# Get recently added items
plex library recent --section 1 --limit 10

# View active sessions, filter with jq
plex sessions list | jq '{user: .User.title, title: .title}'

# Watch history for last 20 items
plex history --limit 20

# Mark item as played
plex scrobble --key 12345

# Get metadata with children
plex metadata show --key 12345
plex metadata children --key 12345

# Create a playlist
plex playlists create --title "My Mix" --type video --uri "server://xyz/library/metadata/123,456"

# View schema for a command
plex schema "library list"
```

### Output with jq

```bash
# Filter libraries by type
plex library list | jq 'select(.type == "movie")'

# Extract specific fields from search results
plex search --query "Trek" | jq '{title, year, type}'

# Count items in a library
plex library items --section 1 | jq -s 'length'

# Get session progress as percentage
plex sessions list | jq '{title, progress: (.viewOffset / .duration * 100)}'
```

## Output Format

- **Single objects** are output as pretty-printed JSON
- **Lists** are output as NDJSON (one JSON object per line) for easy streaming and
  processing with `jq`
- By default, the Plex `MediaContainer` envelope is unwrapped automatically
- Use `--raw` flag (where available) to get the full API response envelope

## Development

```bash
bundle install
bundle exec bin/plex --help
```

## License

MIT License. See [LICENSE](LICENSE) for details.
