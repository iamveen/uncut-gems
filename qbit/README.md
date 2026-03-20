# qbit

A command-line interface for the qBittorrent Web API (v2).

Outputs raw JSON/NDJSON to stdout for easy piping to `jq` and other Unix tools.

## Installation

Add to your Gemfile (requires Bundler 2.3+):

```ruby
gem "qbit", github: "iamveen/uncut-gems", subdir: "qbit"
```

Then run:

```bash
bundle install
```

### From Source

```bash
git clone https://github.com/iamveen/uncut-gems.git
cd uncut-gems/qbit
bundle install
bundle exec bin/qbit --help
```

## Configuration

Set your qBittorrent server URL and credentials via environment variables:

```bash
export QBIT_URL="http://localhost:8080"
export QBIT_USERNAME="admin"
export QBIT_PASSWORD="adminadmin"
```

Or pass them as flags:

```bash
qbit --url http://localhost:8080 --username admin --password secret <command>
```

### Session Management

The CLI automatically manages your session in `~/.cache/qbit/session`. The session
persists across commands until you explicitly log out:

```bash
qbit app logout
```

## Usage

```bash
qbit --help
qbit <command> --help
```

### Commands

| Command | Description |
| --- | --- |
| `torrent list` | List all torrents (NDJSON) |
| `torrent get` | Get detailed properties for a single torrent |
| `torrent files` | List files inside a torrent |
| `torrent trackers` | List trackers for a torrent |
| `torrent peers` | List peers for a torrent |
| `torrent add` | Add a torrent by URL/magnet or local .torrent file |
| `torrent pause` | Pause torrents |
| `torrent resume` | Resume torrents |
| `torrent delete` | Delete torrents (optionally with files) |
| `torrent recheck` | Force piece verification recheck |
| `torrent reannounce` | Force announce to all trackers |
| `torrent rename` | Rename a torrent |
| `torrent move` | Move torrents to a new download path |
| `torrent set-category` | Set or unset category for torrents |
| `torrent add-tags` | Add tags to torrents |
| `torrent remove-tags` | Remove tags from torrents |
| `torrent set-download-limit` | Set per-torrent download speed limit |
| `torrent set-upload-limit` | Set per-torrent upload speed limit |
| `torrent set-share-limits` | Set ratio and seeding time limits |
| `category list` | List all categories |
| `category create` | Create a new category |
| `category edit` | Edit category save path |
| `category delete` | Delete categories |
| `tag list` | List all tags |
| `tag create` | Create new tags |
| `tag delete` | Delete tags |
| `transfer info` | Transfer speed and data stats |
| `transfer speed-limits` | Get global speed limits |
| `transfer set-download-limit` | Set global download speed limit |
| `transfer set-upload-limit` | Set global upload speed limit |
| `app version` | Get app and API version |
| `app preferences` | Get full application preferences |
| `app set-preferences` | Update application preferences |
| `app logout` | Log out and clear session |
| `schema` | Show the output schema for a command |

### Examples

```bash
# List all torrents
qbit torrent list

# List torrents with specific state (use jq)
qbit torrent list | jq 'select(.state == "downloading")'

# Get details for a specific torrent
qbit torrent get --hash abc123def456

# Add a torrent via magnet link
qbit torrent add --url "magnet:?xt=urn:btih:..."

# Add a local .torrent file
qbit torrent add --file ~/Downloads/ubuntu.torrent

# Add torrent to specific category and paused
qbit torrent add --url "magnet:..." --category ISOs --paused

# Pause multiple torrents
qbit torrent pause --hashes hash1,hash2,hash3

# Pause all torrents
qbit torrent pause --hashes all

# Resume torrents
qbit torrent resume --hashes hash1,hash2

# Delete torrents (keep files)
qbit torrent delete --hashes hash1,hash2

# Delete torrents and files
qbit torrent delete --hashes hash1 --delete-files

# List categories
qbit category list

# Create a category with custom save path
qbit category create --name ISOs --save-path /mnt/storage/ISOs

# Add tags to torrents
qbit torrent add-tags --hashes hash1,hash2 --tags "linux,ubuntu"

# Remove specific tags
qbit torrent remove-tags --hashes hash1 --tags "old"

# Remove all tags
qbit torrent remove-tags --hashes hash1 --tags ""

# Set per-torrent download limit (1 MB/s)
qbit torrent set-download-limit --hashes hash1 --limit-bytes 1048576

# Set global upload limit (500 KB/s)
qbit transfer set-upload-limit --limit-bytes 512000

# Get transfer info
qbit transfer info

# View app preferences
qbit app preferences

# Update specific preferences
qbit app set-preferences --json '{"max_active_downloads": 5, "max_active_uploads": 10}'

# View schema for a command
qbit schema "torrent list"
```

### Output with jq

```bash
# Filter by state
qbit torrent list | jq 'select(.state == "pausedDL")'

# Extract specific fields
qbit torrent list | jq '{name, progress, eta, size}'

# Count torrents
qbit torrent list | jq -s 'length'

# Sort by progress
qbit torrent list | jq -s 'sort_by(.progress)'

# Show torrents over 90% complete
qbit torrent list | jq 'select(.progress > 0.9)'

# Get just the names of completed torrents
qbit torrent list | jq -r 'select(.progress == 1.0) | .name'

# Sum total downloaded data
qbit torrent list | jq -s 'map(.downloaded) | add'

# Filter by category and tag
qbit torrent list | jq 'select(.category == "ISOs" and (.tags | contains("ubuntu")))'
```

## Output Format

- **Single objects** are output as pretty-printed JSON
- **Lists** are output as NDJSON (one JSON object per line) for easy streaming and
  processing with `jq`
- Use `--raw` flag (where available) to get the full API response instead of unwrapped
  records
- Hash parameters accept comma-separated values or the special string `"all"`

## Development

```bash
bundle install
bundle exec bin/qbit --help
```

## License

MIT License. See [LICENSE](LICENSE) for details.
