# TMDB CLI

A composable CLI wrapper around
[The Movie Database (TMDB) API](https://www.themoviedb.org/documentation/api).
Built for automation, scripting, and LLM agent use.

**Design philosophy:**
- Outputs raw JSON/NDJSON to stdout
- All other output goes to stderr
- Use `jq` for field selection, filtering, and reshaping
- Schema introspection for discoverable output structure

Part of the [uncut-gems](https://github.com/iamveen/uncut-gems) monorepo.

## Installation

### From Source

```bash
git clone https://github.com/iamveen/uncut-gems.git
cd uncut-gems/tmdb
bundle install
```

### From GitHub (Bundler 2.3+)

```ruby
# Gemfile
gem "tmdb", github: "iamveen/uncut-gems", subdir: "tmdb"
```

Then `bundle install`.

### Build and Install Locally

```bash
cd tmdb
gem build tmdb.gemspec
gem install ./tmdb-*.gem
rm ./tmdb-*.gem
```

## Configuration

The TMDB CLI requires an API key from The Movie Database.

**Get your API key:**
1. Sign up at [themoviedb.org](https://www.themoviedb.org/)
2. Go to Settings → API
3. Request an API key (free for personal use)

**Set your API key:**

```bash
export TMDB_API_KEY="your_api_key_here"
```

Or pass it as a flag:

```bash
tmdb --api-key="your_api_key_here" search movie --query="Inception"
```

## Usage

### Basic Examples

```bash
# Search for a movie
tmdb search movie --query="The Matrix"

# Get movie details
tmdb movie details --id=603

# Search for TV shows
tmdb search tv --query="Breaking Bad"

# Get trending movies this week
tmdb trending movie week

# Discover highly-rated sci-fi movies from 2020
tmdb discover movie --with-genres=878 --year=2020 --sort-by=vote_average.desc

# Search for a person
tmdb search person --query="Tom Hanks"

# Get person details with credits appended
tmdb person details --id=31 --append-to-response=movie_credits,tv_credits
```

### Using with jq

```bash
# Get just the titles from a search
tmdb search movie --query="Star Wars" | jq -r '.title'

# Get movie IDs and titles
tmdb search movie --query="Star Wars" | jq '{id, title}'

# Find movies with high ratings
tmdb movie popular | jq 'select(.vote_average > 8) | {title, vote_average}'

# Get the first result's ID
tmdb search movie --query="Inception" | head -1 | jq '.id'

# Combine with xargs to get details for each result
tmdb search movie --query="Matrix" | jq -r '.id' | head -3 | \
  xargs -I {} tmdb movie details --id={}
```

### Output Formats

**Single objects** (e.g., `movie details`) output pretty-printed JSON:

```json
{
  "id": 603,
  "title": "The Matrix",
  "release_date": "1999-03-30",
  ...
}
```

**Lists** (e.g., `search movie`) output NDJSON (one object per line):

```json
{"id": 603, "title": "The Matrix", ...}
{"id": 604, "title": "The Matrix Reloaded", ...}
{"id": 605, "title": "The Matrix Revolutions", ...}
```

**Raw API envelopes** can be preserved with `--raw`:

```bash
tmdb search movie --query="Inception" --raw
```

## Commands

### Search

| Command | Description |
| --- | --- |
| `search movie` | Search for movies by title |
| `search tv` | Search for TV shows by name |
| `search person` | Search for people (actors, directors, crew) |
| `search multi` | Multi-search across all media types |

### Movie

| Command | Description |
| --- | --- |
| `movie details` | Get detailed movie information |
| `movie credits` | Get cast and crew |
| `movie images` | Get posters and backdrops |
| `movie videos` | Get trailers and teasers |
| `movie recommendations` | Get similar movie recommendations |
| `movie similar` | Get similar movies |
| `movie popular` | Get popular movies |
| `movie top-rated` | Get top-rated movies |
| `movie now-playing` | Get movies currently in theaters |
| `movie upcoming` | Get upcoming movies |

### TV

| Command | Description |
| --- | --- |
| `tv details` | Get detailed TV show information |
| `tv credits` | Get cast and crew |
| `tv images` | Get posters and backdrops |
| `tv videos` | Get trailers and teasers |
| `tv season` | Get details about a specific season |
| `tv episode` | Get details about a specific episode |
| `tv recommendations` | Get similar TV show recommendations |
| `tv similar` | Get similar TV shows |
| `tv popular` | Get popular TV shows |
| `tv top-rated` | Get top-rated TV shows |
| `tv on-the-air` | Get TV shows currently on the air |
| `tv airing-today` | Get TV shows airing today |

### Person

| Command | Description |
| --- | --- |
| `person details` | Get detailed person information |
| `person movie-credits` | Get movie credits (cast and crew) |
| `person tv-credits` | Get TV credits (cast and crew) |
| `person combined-credits` | Get combined movie and TV credits |
| `person images` | Get profile images |
| `person popular` | Get popular people |

### Discover

| Command | Description |
| --- | --- |
| `discover movie` | Discover movies with powerful filtering |
| `discover tv` | Discover TV shows with powerful filtering |

**Discover movie filters:**
- `--sort-by` - Sort results (popularity.desc, release_date.desc, vote_average.desc,
  etc.)
- `--with-genres` - Filter by genre IDs (comma-separated)
- `--with-keywords` - Filter by keyword IDs
- `--with-cast` - Filter by cast member IDs
- `--with-crew` - Filter by crew member IDs
- `--release-date-gte/lte` - Filter by release date range
- `--vote-average-gte/lte` - Filter by rating range
- `--year` - Filter by release year
- And more! Use `tmdb discover movie --help` for all options

### Trending

| Command | Description |
| --- | --- |
| `trending <media_type> <time_window>` | Get trending items |

**Media types:** `all`, `movie`, `tv`, `person`\
**Time windows:** `day`, `week`

Examples:
```bash
tmdb trending movie week
tmdb trending tv day
tmdb trending all week
```

### Schema Introspection

```bash
# List all available schemas
tmdb schema

# Get schema for a specific command
tmdb schema "search movie"
tmdb schema "movie details"
```

## Common Flags

Most commands support these flags:

- `--language` - Language code (default: `en-US`)
- `--page` - Page number for paginated results (default: `1`)
- `--raw` - Return full API envelope instead of unwrapped data

## Genre IDs

Common genre IDs for filtering:

**Movies:**
- 28 - Action
- 12 - Adventure
- 16 - Animation
- 35 - Comedy
- 80 - Crime
- 99 - Documentary
- 18 - Drama
- 10751 - Family
- 14 - Fantasy
- 36 - History
- 27 - Horror
- 10402 - Music
- 9648 - Mystery
- 10749 - Romance
- 878 - Science Fiction
- 10770 - TV Movie
- 53 - Thriller
- 10752 - War
- 37 - Western

**TV Shows:**
- 10759 - Action & Adventure
- 16 - Animation
- 35 - Comedy
- 80 - Crime
- 99 - Documentary
- 18 - Drama
- 10751 - Family
- 10762 - Kids
- 9648 - Mystery
- 10763 - News
- 10764 - Reality
- 10765 - Sci-Fi & Fantasy
- 10766 - Soap
- 10767 - Talk
- 10768 - War & Politics
- 37 - Western

## Image URLs

TMDB returns image paths like `/abc123.jpg`. To construct full URLs:

```bash
# Poster/profile images
https://image.tmdb.org/t/p/w500/abc123.jpg

# Backdrop images
https://image.tmdb.org/t/p/original/abc123.jpg
```

**Available sizes:**
- `w92`, `w154`, `w185`, `w342`, `w500`, `w780`, `original` (posters/profiles)
- `w300`, `w780`, `w1280`, `original` (backdrops)

Example with jq:
```bash
tmdb search movie --query="Inception" | \
  jq -r '"https://image.tmdb.org/t/p/w500" + .poster_path'
```

## API Rate Limits

TMDB API has rate limits:
- 40 requests per 10 seconds
- Free tier is generous for personal use

If you hit rate limits, the CLI will return an error.
Consider adding delays between bulk requests.

## Links

- [TMDB API Documentation](https://developers.themoviedb.org/3)
- [Uncut Gems Repository](https://github.com/iamveen/uncut-gems)
- [Get API Key](https://www.themoviedb.org/settings/api)

## License

MIT - See [LICENSE](../LICENSE) file in the main repository.
