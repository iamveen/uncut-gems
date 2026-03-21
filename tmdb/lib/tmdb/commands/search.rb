module TMDB
  module Commands
    def self.register_search(prog)
      prog.desc "Search operations - multi-search across movies, TV shows, and people"
      prog.command :search do |c|
        # ── search movie ───────────────────────────────────────────────────────
        c.desc "Search for movies by title. Returns NDJSON with one movie per line."
        c.command :movie do |movie|
          movie.flag :query, desc: "Search query (movie title)", required: true
          movie.flag :year, desc: "Filter by release year", type: Integer
          movie.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          movie.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          movie.switch "include-adult", desc: "Include adult content", negatable: false
          movie.switch :raw, desc: "Return full API envelope", negatable: false

          movie.action do |g, opts, _|
            params = {
              query: opts[:query],
              year: opts[:year],
              page: opts[:page],
              language: opts[:language],
              include_adult: opts["include-adult"]
            }
            body = g[:client].get("/search/movie", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── search tv ──────────────────────────────────────────────────────────
        c.desc "Search for TV shows by name. Returns NDJSON with one show per line."
        c.command :tv do |tv|
          tv.flag :query, desc: "Search query (TV show name)", required: true
          tv.flag "first-air-date-year", desc: "Filter by first air date year", type: Integer
          tv.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          tv.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          tv.switch "include-adult", desc: "Include adult content", negatable: false
          tv.switch :raw, desc: "Return full API envelope", negatable: false

          tv.action do |g, opts, _|
            params = {
              query: opts[:query],
              first_air_date_year: opts["first-air-date-year"],
              page: opts[:page],
              language: opts[:language],
              include_adult: opts["include-adult"]
            }
            body = g[:client].get("/search/tv", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── search person ──────────────────────────────────────────────────────
        c.desc "Search for people (actors, directors, crew). Returns NDJSON with one person per line."
        c.command :person do |person|
          person.flag :query, desc: "Search query (person name)", required: true
          person.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          person.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          person.switch "include-adult", desc: "Include adult content", negatable: false
          person.switch :raw, desc: "Return full API envelope", negatable: false

          person.action do |g, opts, _|
            params = {
              query: opts[:query],
              page: opts[:page],
              language: opts[:language],
              include_adult: opts["include-adult"]
            }
            body = g[:client].get("/search/person", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── search multi ───────────────────────────────────────────────────────
        c.desc "Multi-search across movies, TV shows, and people. Returns NDJSON with media_type field."
        c.command :multi do |multi|
          multi.flag :query, desc: "Search query", required: true
          multi.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          multi.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          multi.switch "include-adult", desc: "Include adult content", negatable: false
          multi.switch :raw, desc: "Return full API envelope", negatable: false

          multi.action do |g, opts, _|
            params = {
              query: opts[:query],
              page: opts[:page],
              language: opts[:language],
              include_adult: opts["include-adult"]
            }
            body = g[:client].get("/search/multi", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end
      end
    end
  end
end
