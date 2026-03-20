require "json"
require "time"

HISTORY_CACHE_PATH = ENV["PLEX_HISTORY_CACHE"] || File.join(Dir.home, ".pi", "plex-history.json")

module Plex
  module Commands
    def self.register_history(prog)
      prog.desc "Watch history with filtering and pagination (NDJSON). " \
                "Syncs incrementally from GET /status/sessions/history/all before each query."
      prog.command :history do |c|
        c.flag :title,      desc: "Case-insensitive substring matched against title, grandparentTitle, parentTitle"
        c.flag :type,       desc: "Exact media type: movie, episode, track, clip, etc."
        c.flag "account-id", desc: "Filter to a specific Plex user account ID", type: Integer
        c.flag "device-id",  desc: "Filter to a specific device ID"
        c.flag "imdb-id",    desc: "Filter to a specific IMDB ID (e.g. tt0133093)"
        c.flag "tmdb-id",    desc: "Filter to a specific TMDB ID"
        c.flag "tvdb-id",    desc: "Filter to a specific TVDB ID"
        c.flag :after,      desc: "Only records viewed after this Unix timestamp (seconds)", type: Integer
        c.flag :before,     desc: "Only records viewed before this Unix timestamp (seconds)", type: Integer
        c.flag :sort,       desc: "Sort: viewedAt:desc (default), viewedAt:asc, title:asc, title:desc",
                            default_value: "viewedAt:desc"
        c.flag :limit,      desc: "Max records to return (default 50)", type: Integer, default_value: 50
        c.flag :offset,     desc: "Pagination offset", type: Integer, default_value: 0
        c.switch :all,      desc: "Remove the default 50-record limit and return everything matching",
                            negatable: false
        c.switch "no-sync", desc: "Skip the incremental sync and query cached data only",
                            negatable: false
        c.switch :raw,      desc: "Return the full history cache envelope", negatable: false
        c.action do |g, opts, _|
          sync_history(g[:client]) unless opts["no-sync"]

          unless File.exist?(HISTORY_CACHE_PATH)
            $stderr.puts "No history cache found. Run without --no-sync to populate it."
            exit 1
          end

          cache = JSON.parse(File.read(HISTORY_CACHE_PATH))

          if opts[:raw]
            Plex::Output.pretty(cache)
            next
          end

          items = cache["items"] || []

          if (q = opts[:title])
            q = q.downcase
            items = items.select do |i|
              [i["title"], i["grandparentTitle"], i["parentTitle"]].any? do |t|
                t&.downcase&.include?(q)
              end
            end
          end

          items = items.select { |i| i["type"] == opts[:type] }             if opts[:type]
          items = items.select { |i| i["accountID"] == opts["account-id"] } if opts["account-id"]
          items = items.select { |i| i["deviceID"].to_s == opts["device-id"].to_s } if opts["device-id"]
          items = items.select { |i| i["imdb_id"] == opts["imdb-id"] }      if opts["imdb-id"]
          items = items.select { |i| i["tmdb_id"] == opts["tmdb-id"] }      if opts["tmdb-id"]
          items = items.select { |i| i["tvdb_id"] == opts["tvdb-id"] }      if opts["tvdb-id"]
          items = items.select { |i| i["viewedAt"].to_i > opts[:after] }    if opts[:after]
          items = items.select { |i| i["viewedAt"].to_i < opts[:before] }   if opts[:before]

          sort_field, sort_dir = opts[:sort].split(":")
          items = items.sort_by { |i| i[sort_field] || "" }
          items = items.reverse if sort_dir == "desc"

          total      = items.size
          page_offset = opts[:offset]
          limit      = opts[:all] ? total : opts[:limit]
          page       = items.slice(page_offset, limit) || []

          page.each do |item|
            item["viewedAtISO"] = item["viewedAt"] ? Time.at(item["viewedAt"]).utc.iso8601 : nil
            puts JSON.generate(item)
          end

          $stderr.puts "# #{page.size} of #{total} records (offset #{page_offset})" if $stderr.isatty
        end
      end
    end

    # ── history sync ──────────────────────────────────────────────────────────

    def self.sync_history(client)
      server_url = client.instance_variable_get(:@url)
      existing = if File.exist?(HISTORY_CACHE_PATH)
        JSON.parse(File.read(HISTORY_CACHE_PATH)) rescue nil
      end

      incremental = existing && existing["serverUrl"] == server_url &&
                    (existing["items"]&.size || 0) > 0

      since_viewed_at = incremental \
        ? existing["items"].map { |i| i["viewedAt"].to_i }.max
        : 0

      batch_size = 100
      fetched    = []
      offset     = 0
      exhausted  = false

      until exhausted
        res = client.get("/status/sessions/history/all", {
          sort:                      "viewedAt:desc",
          "X-Plex-Container-Size":   batch_size,
          "X-Plex-Container-Start":  offset,
          "includeGuids":            1,
        })

        mc    = res.dig("MediaContainer") || {}
        batch = (mc["Metadata"] || []).map do |m|
          guids = Array(m["Guid"])
          {
            "historyKey"       => m["historyKey"],
            "ratingKey"        => m["ratingKey"],
            "title"            => m["title"],
            "type"             => m["type"],
            "grandparentTitle" => m["grandparentTitle"],
            "parentTitle"      => m["parentTitle"],
            "viewedAt"         => m["viewedAt"].to_i,
            "accountID"        => m["accountID"].to_i,
            "deviceID"         => m["deviceID"]&.to_s,
            "duration"         => m["duration"]&.to_i,
            "imdb_id"          => Plex::GuidHelper.extract(guids, "imdb"),
            "tmdb_id"          => Plex::GuidHelper.extract(guids, "tmdb"),
            "tvdb_id"          => Plex::GuidHelper.extract(guids, "tvdb"),
          }
        end

        break if batch.empty?

        if incremental
          new_in_batch = batch.select { |i| i["viewedAt"] > since_viewed_at }
          fetched.concat(new_in_batch)
          exhausted = true if new_in_batch.size < batch.size
        else
          fetched.concat(batch)
        end

        offset += batch_size
        total_on_server = (mc["totalSize"] || mc["size"] || 0).to_i
        exhausted = true if offset >= total_on_server
      end

      merged = if incremental && existing
        existing_keys = existing["items"].map { |i| i["historyKey"].to_s }.to_set
        deduped = fetched.reject { |i| existing_keys.include?(i["historyKey"].to_s) }
        deduped + existing["items"]
      else
        fetched
      end

      FileUtils.mkdir_p(File.dirname(HISTORY_CACHE_PATH))
      File.write(HISTORY_CACHE_PATH, JSON.generate({
        "cachedAt"   => Time.now.utc.iso8601,
        "serverUrl"  => server_url,
        "totalItems" => merged.size,
        "items"      => merged,
      }))

      $stderr.puts "# History synced: #{fetched.size} new, #{merged.size} total cached" if $stderr.isatty
    end
  end
end
