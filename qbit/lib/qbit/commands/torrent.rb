# frozen_string_literal: true

module Qbit
  module Commands
    def self.register_torrent(prog)
      prog.desc "Torrent management: list, inspect, add, control, and configure torrents"
      prog.command :torrent do |t|

        # ── list ───────────────────────────────────────────────────────────────
        t.desc "GET /api/v2/torrents/info — List torrents (NDJSON). " \
               "Default cap: 50. Use --all for no limit. " \
               "Filter by state with jq, e.g.: qbit torrent list | jq 'select(.state==\"pausedDL\")'"
        t.command :list do |c|
          c.flag :category, desc: "Filter by category name (API-level)"
          c.flag :tag,      desc: "Filter by tag name (API-level)"
          c.flag :sort,     desc: "Field to sort by (e.g. progress, added_on, size, ratio)"
          c.switch :reverse, negatable: false, desc: "Reverse sort order"
          c.flag :hashes,   desc: "Comma-separated hashes to fetch (e.g. abc123,def456)"
          c.flag :limit,    desc: "Max torrents to return (default: 50). Use --all for no limit.",
                            type: Integer, default_value: 50
          c.switch :all,    negatable: false, desc: "Return all torrents, removing the default limit"
          c.switch :raw,    negatable: false, desc: "Return full JSON array instead of NDJSON"
          c.action do |g, opts, _|
            params = {
              category: opts[:category],
              tag:      opts[:tag],
              sort:     opts[:sort],
              reverse:  opts[:reverse] ? "true" : nil,
              hashes:   opts[:hashes] ? Qbit::Output.hashes_param(opts[:hashes]) : nil,
              limit:    opts[:all] ? nil : opts[:limit],
            }
            body = g[:client].get("/torrents/info", params)
            Qbit::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── get ────────────────────────────────────────────────────────────────
        t.desc "GET /api/v2/torrents/properties — Detailed properties for a single torrent (JSON)"
        t.command :get do |c|
          c.flag :hash, desc: "Torrent hash (required)", required: true
          c.action do |g, opts, _|
            body = g[:client].get("/torrents/properties", hash: opts[:hash])
            # Inject hash for convenience — the properties endpoint doesn't echo it
            body = body.merge("hash" => opts[:hash]) if body.is_a?(Hash)
            Qbit::Output.pretty(body)
          end
        end

        # ── files ──────────────────────────────────────────────────────────────
        t.desc "GET /api/v2/torrents/files — Files inside a torrent (NDJSON). " \
               "priority: 0=skip, 1=normal, 6=high, 7=max"
        t.command :files do |c|
          c.flag :hash, desc: "Torrent hash (required)", required: true
          c.switch :raw, negatable: false, desc: "Return full JSON array instead of NDJSON"
          c.action do |g, opts, _|
            body = g[:client].get("/torrents/files", hash: opts[:hash])
            Qbit::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── trackers ───────────────────────────────────────────────────────────
        t.desc "GET /api/v2/torrents/trackers — Trackers for a torrent (NDJSON). " \
               "status: 0=disabled, 1=not_contacted, 2=working, 3=updating, 4=not_working"
        t.command :trackers do |c|
          c.flag :hash, desc: "Torrent hash (required)", required: true
          c.switch :raw, negatable: false, desc: "Return full JSON array instead of NDJSON"
          c.action do |g, opts, _|
            body = g[:client].get("/torrents/trackers", hash: opts[:hash])
            Qbit::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── peers ──────────────────────────────────────────────────────────────
        t.desc "GET /api/v2/sync/torrentPeers — Peers for a torrent (NDJSON). " \
               "Fetches a full snapshot (rid=0). Adds 'address' (ip:port) to each record."
        t.command :peers do |c|
          c.flag :hash, desc: "Torrent hash (required)", required: true
          c.switch :raw, negatable: false, desc: "Return raw API response (includes full_update, rid)"
          c.action do |g, opts, _|
            body = g[:client].get("/sync/torrentPeers", hash: opts[:hash], rid: 0)
            if opts[:raw]
              Qbit::Output.pretty(body)
            else
              peers = body.is_a?(Hash) ? (body["peers"] || {}) : {}
              Qbit::Output.ndjson(peers.map { |address, info| info.merge("address" => address) })
            end
          end
        end

        # ── add ────────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/add — Add a torrent by URL/magnet or local .torrent file. " \
               "Use --url for magnets and HTTP links (comma-separate for multiple), " \
               "--file for a local .torrent file."
        t.command :add do |c|
          c.flag :url,          desc: "Magnet link or .torrent URL. Comma-separate for multiple."
          c.flag :file,         desc: "Path to a local .torrent file"
          c.flag "save-path",   desc: "Download directory (overrides category default)"
          c.flag :category,     desc: "Assign to a category"
          c.flag :tags,         desc: "Comma-separated tags to assign"
          c.flag :rename,       desc: "Rename the torrent"
          c.switch :paused,     negatable: false, desc: "Add in paused state"
          c.switch :sequential, negatable: false, desc: "Enable sequential download"
          c.action do |g, opts, _|
            abort "Error: provide --url or --file, not both" if opts[:url] && opts[:file]
            abort "Error: --url or --file is required"       unless opts[:url] || opts[:file]

            params = {
              savepath:           opts["save-path"],
              category:           opts[:category],
              tags:               opts[:tags] ? Qbit::Output.tags_param(opts[:tags]) : nil,
              rename:             opts[:rename],
              paused:             opts[:paused]     ? "true" : nil,
              sequentialDownload: opts[:sequential] ? "true" : nil,
            }

            body = if opts[:file]
                     path = File.expand_path(opts[:file])
                     abort "Error: file not found: #{path}" unless File.exist?(path)
                     g[:client].post_file("/torrents/add", path, params)
                   else
                     urls = opts[:url].split(",").map(&:strip).join("\n")
                     g[:client].post("/torrents/add", params.merge(urls: urls))
                   end

            Qbit::Output.json(body)
          end
        end

        # ── pause ──────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/pause — Pause one or more torrents"
        t.command :pause do |c|
          c.flag :hashes, desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/pause", hashes: Qbit::Output.hashes_param(opts[:hashes]))
            Qbit::Output.json(body)
          end
        end

        # ── resume ─────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/resume — Resume one or more torrents"
        t.command :resume do |c|
          c.flag :hashes, desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/resume", hashes: Qbit::Output.hashes_param(opts[:hashes]))
            Qbit::Output.json(body)
          end
        end

        # ── delete ─────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/delete — Delete one or more torrents. " \
               "Add --delete-files to also remove data from disk."
        t.command :delete do |c|
          c.flag :hashes,        desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.switch "delete-files", negatable: false, desc: "Also delete downloaded data from disk"
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/delete",
              hashes:      Qbit::Output.hashes_param(opts[:hashes]),
              deleteFiles: opts["delete-files"] ? "true" : "false"
            )
            Qbit::Output.json(body)
          end
        end

        # ── recheck ────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/recheck — Force a piece-verification recheck"
        t.command :recheck do |c|
          c.flag :hashes, desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/recheck", hashes: Qbit::Output.hashes_param(opts[:hashes]))
            Qbit::Output.json(body)
          end
        end

        # ── reannounce ─────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/reannounce — Force an announce to all trackers"
        t.command :reannounce do |c|
          c.flag :hashes, desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/reannounce", hashes: Qbit::Output.hashes_param(opts[:hashes]))
            Qbit::Output.json(body)
          end
        end

        # ── rename ─────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/rename — Rename a torrent"
        t.command :rename do |c|
          c.flag :hash, desc: "Torrent hash (required)", required: true
          c.flag :name, desc: "New name (required)", required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/rename", hash: opts[:hash], name: opts[:name])
            Qbit::Output.json(body)
          end
        end

        # ── move ───────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/setLocation — Move torrents to a new download path"
        t.command :move do |c|
          c.flag :hashes, desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.flag :path,   desc: "Absolute destination path (required)", required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/setLocation",
              hashes:   Qbit::Output.hashes_param(opts[:hashes]),
              location: opts[:path]
            )
            Qbit::Output.json(body)
          end
        end

        # ── set-category ───────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/setCategory — Set (or unset) category for torrents"
        t.command :"set-category" do |c|
          c.flag :hashes,   desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.flag :category, desc: 'Category name. Pass "" to unset. (required)', required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/setCategory",
              hashes:   Qbit::Output.hashes_param(opts[:hashes]),
              category: opts[:category]
            )
            Qbit::Output.json(body)
          end
        end

        # ── add-tags ───────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/addTags — Add tags to torrents (existing tags preserved)"
        t.command :"add-tags" do |c|
          c.flag :hashes, desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.flag :tags,   desc: "Comma-separated tag names to add (required)", required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/addTags",
              hashes: Qbit::Output.hashes_param(opts[:hashes]),
              tags:   Qbit::Output.tags_param(opts[:tags])
            )
            Qbit::Output.json(body)
          end
        end

        # ── remove-tags ────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/removeTags — Remove tags from torrents. " \
               'Pass --tags "" to remove all tags.'
        t.command :"remove-tags" do |c|
          c.flag :hashes, desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.flag :tags,   desc: 'Comma-separated tag names to remove. "" removes all. (required)', required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/removeTags",
              hashes: Qbit::Output.hashes_param(opts[:hashes]),
              tags:   Qbit::Output.tags_param(opts[:tags])
            )
            Qbit::Output.json(body)
          end
        end

        # ── set-download-limit ─────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/setDownloadLimit — Per-torrent download speed cap. " \
               "Pass 0 to remove the limit."
        t.command :"set-download-limit" do |c|
          c.flag :hashes,       desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.flag "limit-bytes", desc: "Speed limit in bytes/s. 0 = unlimited. (required)",
                                required: true, type: Integer
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/setDownloadLimit",
              hashes: Qbit::Output.hashes_param(opts[:hashes]),
              limit:  opts["limit-bytes"]
            )
            Qbit::Output.json(body)
          end
        end

        # ── set-upload-limit ───────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/setUploadLimit — Per-torrent upload speed cap. " \
               "Pass 0 to remove the limit."
        t.command :"set-upload-limit" do |c|
          c.flag :hashes,       desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.flag "limit-bytes", desc: "Speed limit in bytes/s. 0 = unlimited. (required)",
                                required: true, type: Integer
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/setUploadLimit",
              hashes: Qbit::Output.hashes_param(opts[:hashes]),
              limit:  opts["limit-bytes"]
            )
            Qbit::Output.json(body)
          end
        end

        # ── set-share-limits ───────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/setShareLimits — Set ratio/seeding-time limits. " \
               "-1 = disabled, -2 = use global default."
        t.command :"set-share-limits" do |c|
          c.flag :hashes,              desc: 'Comma-separated hashes, or "all" (required)', required: true
          c.flag "ratio-limit",        desc: "Max share ratio. -1=disabled, -2=global default. (required)",
                                       required: true, type: Float
          c.flag "seeding-time-limit", desc: "Max seeding time in minutes. -1=disabled, -2=global default. (required)",
                                       required: true, type: Integer
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/setShareLimits",
              hashes:           Qbit::Output.hashes_param(opts[:hashes]),
              ratioLimit:       opts["ratio-limit"],
              seedingTimeLimit: opts["seeding-time-limit"]
            )
            Qbit::Output.json(body)
          end
        end

      end
    end
  end
end
