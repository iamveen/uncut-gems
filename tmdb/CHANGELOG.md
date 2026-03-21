# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-03-21

### Fixed

- Fixed 404 errors on all API requests by correcting base URL path handling
  - Changed BASE_URL from `https://api.themoviedb.org/3` to
    `https://api.themoviedb.org/3/`
  - Removed leading slashes from all API endpoint paths to work with Faraday relative
    path resolution
- Fixed trending command to use flags instead of positional arguments
  - Changed from `tmdb trending movie week` to
    `tmdb trending --media-type=movie --time-window=week`
  - Added default values: `--media-type=all` and `--time-window=week`

### Changed

- Updated README with corrected trending command syntax and examples

## [1.0.0] - 2026-03-20

### Added

- Initial release of TMDB CLI wrapper
- Search commands for movies, TV shows, people, and multi-search
- Movie commands: details, credits, images, videos, recommendations, similar, popular,
  top-rated, now-playing, upcoming
- TV commands: details, credits, images, videos, season, episode, recommendations,
  similar, popular, top-rated, on-the-air, airing-today
- Person commands: details, movie-credits, tv-credits, combined-credits, images, popular
- Discover commands with extensive filtering for movies and TV shows
- Trending command for movies, TV shows, and people
- Schema introspection support via `tmdb schema` command
- JSON/NDJSON output with `--raw` flag for full API envelopes
- Environment variable support for API key (TMDB_API_KEY)
