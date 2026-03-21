require "json"
require "time"

module Plex
  module Commands
    def self.register_movie(prog)
      prog.desc "High-level movie operations keyed by IMDB ID"
      prog.command :movie do |mov|

        # ── exists ──────────────────────────────────────────────────────────
        mov.desc "Check if a movie exists in your library (exit 0=yes, 1=no)"
        mov.command :exists do |c|
          c.flag :imdb, desc: "IMDB ID (with or without tt prefix)", required: true
          c.switch :json, desc: "Output JSON instead of exit code", negatable: false

          c.action do |g, opts, _|
            imdb_id = normalize_imdb(opts[:imdb])
            result = find_by_imdb(g[:client], imdb_id)

            if opts[:json]
              puts JSON.generate({
                exists: !result.nil?,
                imdb_id: imdb_id,
                title: result&.dig("title"),
                year: result&.dig("year"),
                ratingKey: result&.dig("ratingKey")
              })
              # Return normally for success
            else
              # Use Process.exit to bypass GLI's exit handling
              Process.exit(result.nil? ? 1 : 0)
            end
          end
        end

        # ── get ─────────────────────────────────────────────────────────────
        mov.desc "Get full metadata for a movie by IMDB ID (same as 'metadata get')"
        mov.command :get do |c|
          c.flag :imdb, desc: "IMDB ID (with or without tt prefix)", required: true
          c.switch :raw, desc: "Return full API envelope", negatable: false

          c.action do |g, opts, _|
            imdb_id = normalize_imdb(opts[:imdb])
            item = find_by_imdb(g[:client], imdb_id)

            unless item
              $stderr.puts "Error: Movie with IMDB ID #{imdb_id} not found in library"
              Process.exit(1)
            end

            # Now fetch full metadata using ratingKey
            rating_key = item["ratingKey"]
            body = g[:client].get("/library/metadata/#{rating_key}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── watched ─────────────────────────────────────────────────────────
        mov.desc "Check if a movie has been watched (exit 0=yes, 1=no)"
        mov.command :watched do |c|
          c.flag :imdb, desc: "IMDB ID (with or without tt prefix)", required: true
          c.flag :user, desc: "Check for a specific user (by account name)"
          c.switch :json, desc: "Output JSON instead of exit code", negatable: false

          c.action do |g, opts, _|
            imdb_id = normalize_imdb(opts[:imdb])

            # First ensure movie exists
            item = find_by_imdb(g[:client], imdb_id)
            unless item
              if opts[:json]
                puts JSON.generate({ watched: false, exists: false, imdb_id: imdb_id })
                # Return normally for success
                return
              else
                $stderr.puts "Error: Movie with IMDB ID #{imdb_id} not found in library"
                Process.exit(1)
              end
            end

            # Load history cache
            unless File.exist?(HISTORY_CACHE_PATH)
              $stderr.puts "Error: History cache not found. Run 'plex history' first."
              Process.exit(1)
            end

            cache = JSON.parse(File.read(HISTORY_CACHE_PATH))
            history_items = cache["items"] || []

            # Resolve account ID if --user specified
            account_id = if opts[:user]
              resolve_account_id(g[:client], opts[:user])
            else
              nil  # Check all accounts (owner default)
            end

            # Find watch records for this IMDB ID
            watched_records = history_items.select do |h|
              h["imdb_id"] == imdb_id && 
              (account_id.nil? || h["accountID"] == account_id)
            end

            if opts[:json]
              latest = watched_records.max_by { |r| r["viewedAt"].to_i }
              puts JSON.generate({
                watched: !watched_records.empty?,
                exists: true,
                imdb_id: imdb_id,
                title: item["title"],
                viewCount: watched_records.size,
                lastViewedAt: latest&.dig("viewedAt"),
                lastViewedAtISO: latest ? Time.at(latest["viewedAt"]).utc.iso8601 : nil
              })
              # Return normally for success
            else
              # Use Process.exit to bypass GLI's exit handling
              Process.exit(watched_records.empty? ? 1 : 0)
            end
          end
        end

        # ── missing ─────────────────────────────────────────────────────────
        mov.desc "Filter a list of IMDB IDs to only those NOT in your library (NDJSON)"
        mov.command :missing do |c|
          c.flag :imdb, desc: "Comma-separated IMDB IDs (with or without tt prefix)", required: true
          c.switch "include-found", 
                   desc: "Output all IDs with exists status instead of only missing",
                   negatable: false

          c.action do |g, opts, _|
            imdb_ids = opts[:imdb].split(",").map { |id| normalize_imdb(id.strip) }

            # Build lookup cache once
            cache = build_library_cache(g[:client])

            results = imdb_ids.map do |imdb_id|
              item = cache[imdb_id]
              {
                imdb_id: imdb_id,
                exists: !item.nil?,
                title: item&.dig("title"),
                year: item&.dig("year"),
                ratingKey: item&.dig("ratingKey")
              }
            end

            # Filter to missing only unless --include-found
            results = results.reject { |r| r[:exists] } unless opts["include-found"]

            results.each do |r|
              puts JSON.generate(r)
            end
          end
        end

      end
    end

    # ── Helper methods ────────────────────────────────────────────────────

    private

    # Normalize IMDB ID to tt-prefixed format
    def self.normalize_imdb(id)
      id = id.to_s.strip
      id.start_with?("tt") ? id : "tt#{id}"
    end

    # Cache for library lookups (module-level, persists for CLI invocation)
    @library_cache = nil

    # Build IMDB → item lookup from all movie sections
    def self.build_library_cache(client)
      return @library_cache if @library_cache

      $stderr.puts "# Building movie library cache..." if $stderr.isatty

      sections_body = client.get("/library/sections")
      sections = sections_body.dig("MediaContainer", "Directory") || []
      movie_sections = sections.select { |s| s["type"] == "movie" }

      if movie_sections.empty?
        $stderr.puts "Error: No movie sections found"
        Process.exit(1)
      end

      @library_cache = {}

      movie_sections.each do |section|
        section_key = section["key"]

        # Fetch all movies with GUIDs (pagination not needed for most libraries)
        body = client.get("/library/sections/#{section_key}/all", {
          type: 1,
          includeGuids: 1,
          "X-Plex-Container-Size": 10000  # Large enough for most libraries
        })

        items = body.dig("MediaContainer", "Metadata") || []
        items.each do |item|
          guids = Array(item["Guid"])
          imdb_id = Plex::GuidHelper.extract(guids, "imdb")

          # Store full item keyed by IMDB ID (first match wins)
          @library_cache[imdb_id] ||= {
            "ratingKey" => item["ratingKey"],
            "title" => item["title"],
            "year" => item["year"],
            "type" => item["type"],
            "imdb_id" => imdb_id
          } if imdb_id
        end
      end

      $stderr.puts "# Library cache: #{@library_cache.size} movies" if $stderr.isatty
      @library_cache
    end

    # Find a movie by IMDB ID (uses cache)
    def self.find_by_imdb(client, imdb_id)
      cache = build_library_cache(client)
      cache[imdb_id]
    end

    # Resolve account name to account ID
    def self.resolve_account_id(client, account_name)
      body = client.get("/accounts")
      accounts = body.dig("MediaContainer", "Account") || []

      account = accounts.find { |a| a["name"]&.downcase == account_name.downcase }

      unless account
        $stderr.puts "Error: Account '#{account_name}' not found"
        $stderr.puts "Available accounts:"
        accounts.each { |a| $stderr.puts "  - #{a["name"]}" }
        Process.exit(1)
      end

      account["id"].to_i
    end
  end
end
