module TMDB
  module Commands
    def self.register_discover(prog)
      prog.desc "Discover movies and TV shows with powerful filtering options"
      prog.command :discover do |c|
        # ── discover movie ─────────────────────────────────────────────────────
        c.desc "Discover movies with filtering and sorting. Returns NDJSON."
        c.command :movie do |movie|
          movie.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          movie.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          movie.flag :region, desc: "ISO 3166-1 code (e.g., US)"
          movie.flag "sort-by", desc: "Sort by field (e.g., popularity.desc, release_date.desc, vote_average.desc)"
          movie.flag "with-genres", desc: "Comma-separated genre IDs"
          movie.flag "with-keywords", desc: "Comma-separated keyword IDs"
          movie.flag "with-cast", desc: "Comma-separated person IDs (cast)"
          movie.flag "with-crew", desc: "Comma-separated person IDs (crew)"
          movie.flag "with-companies", desc: "Comma-separated company IDs"
          movie.flag "release-date-gte", desc: "Min release date (YYYY-MM-DD)"
          movie.flag "release-date-lte", desc: "Max release date (YYYY-MM-DD)"
          movie.flag "vote-average-gte", desc: "Min vote average", type: Float
          movie.flag "vote-average-lte", desc: "Max vote average", type: Float
          movie.flag "vote-count-gte", desc: "Min vote count", type: Integer
          movie.flag "with-runtime-gte", desc: "Min runtime (minutes)", type: Integer
          movie.flag "with-runtime-lte", desc: "Max runtime (minutes)", type: Integer
          movie.flag :year, desc: "Release year", type: Integer
          movie.switch "include-adult", desc: "Include adult content", negatable: false
          movie.switch "include-video", desc: "Include video content", negatable: false
          movie.switch :raw, desc: "Return full API envelope", negatable: false

          movie.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language],
              region: opts[:region],
              sort_by: opts["sort-by"],
              with_genres: opts["with-genres"],
              with_keywords: opts["with-keywords"],
              with_cast: opts["with-cast"],
              with_crew: opts["with-crew"],
              with_companies: opts["with-companies"],
              "release_date.gte": opts["release-date-gte"],
              "release_date.lte": opts["release-date-lte"],
              "vote_average.gte": opts["vote-average-gte"],
              "vote_average.lte": opts["vote-average-lte"],
              "vote_count.gte": opts["vote-count-gte"],
              "with_runtime.gte": opts["with-runtime-gte"],
              "with_runtime.lte": opts["with-runtime-lte"],
              year: opts[:year],
              include_adult: opts["include-adult"],
              include_video: opts["include-video"]
            }
            body = g[:client].get("/discover/movie", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── discover tv ────────────────────────────────────────────────────────
        c.desc "Discover TV shows with filtering and sorting. Returns NDJSON."
        c.command :tv do |tv|
          tv.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          tv.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          tv.flag "sort-by", desc: "Sort by field (e.g., popularity.desc, first_air_date.desc, vote_average.desc)"
          tv.flag "with-genres", desc: "Comma-separated genre IDs"
          tv.flag "with-keywords", desc: "Comma-separated keyword IDs"
          tv.flag "with-networks", desc: "Comma-separated network IDs"
          tv.flag "with-companies", desc: "Comma-separated company IDs"
          tv.flag "first-air-date-gte", desc: "Min first air date (YYYY-MM-DD)"
          tv.flag "first-air-date-lte", desc: "Max first air date (YYYY-MM-DD)"
          tv.flag "vote-average-gte", desc: "Min vote average", type: Float
          tv.flag "vote-average-lte", desc: "Max vote average", type: Float
          tv.flag "vote-count-gte", desc: "Min vote count", type: Integer
          tv.flag "first-air-date-year", desc: "First air date year", type: Integer
          tv.switch "include-adult", desc: "Include adult content", negatable: false
          tv.switch :raw, desc: "Return full API envelope", negatable: false

          tv.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language],
              sort_by: opts["sort-by"],
              with_genres: opts["with-genres"],
              with_keywords: opts["with-keywords"],
              with_networks: opts["with-networks"],
              with_companies: opts["with-companies"],
              "first_air_date.gte": opts["first-air-date-gte"],
              "first_air_date.lte": opts["first-air-date-lte"],
              "vote_average.gte": opts["vote-average-gte"],
              "vote_average.lte": opts["vote-average-lte"],
              "vote_count.gte": opts["vote-count-gte"],
              first_air_date_year: opts["first-air-date-year"],
              include_adult: opts["include-adult"]
            }
            body = g[:client].get("/discover/tv", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end
      end
    end
  end
end
