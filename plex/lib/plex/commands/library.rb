module Plex
  module Commands
    def self.register_library(prog)
      prog.desc "Library sections: list, browse, refresh, analyze, and manage"
      prog.command :library do |lib|

        # ── list ──────────────────────────────────────────────────────────────
        lib.desc "GET /library/sections — List all library sections (NDJSON). " \
                 "Each section has a key used in all other library commands."
        lib.command :list do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/library/sections")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── browse ────────────────────────────────────────────────────────────
        lib.desc "GET /library/sections/{key}/all — Browse a section with filters and sorting (NDJSON)"
        lib.command :browse do |c|
          c.flag "section-key", desc: "Section key (from 'library list')", required: true, type: Integer
          c.flag :type,   desc: "Media type integer: 1=movie 2=show 3=season 4=episode 8=artist 9=album 10=track", type: Integer
          c.flag :sort,   desc: "Sort expression e.g. 'rating:desc' or 'addedAt:desc,title'"
          c.flag :limit,  desc: "Max items to return (default 100)", type: Integer, default_value: 100
          c.flag :offset, desc: "Pagination offset", type: Integer, default_value: 0
          c.flag :filter, desc: "Filter as KEY=VALUE (repeatable, e.g. --filter genre=Action --filter 'year>>=2000')",
                          multiple: true
          c.switch :all, desc: "Remove the default 100-item limit", negatable: false
          c.switch "include-guids", desc: "Include imdb_id, tmdb_id, tvdb_id on each record", negatable: false
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            params = {
              type:                        opts[:type],
              sort:                        opts[:sort],
              "X-Plex-Container-Size":     opts[:all] ? nil : opts[:limit],
              "X-Plex-Container-Start":    opts[:offset],
            }
            
            # Add includeGuids parameter if flag is set
            params["includeGuids"] = 1 if opts["include-guids"]
            
            opts[:filter].each do |pair|
              k, v = pair.split("=", 2)
              params[k] = v
            end
            
            body = g[:client].get("/library/sections/#{opts["section-key"]}/all", params.compact)
            
            # Process GUIDs if requested and not raw output
            if opts["include-guids"] && !opts[:raw]
              data, envelope = Plex::Output.unwrap(body)
              
              if data.is_a?(Array)
                data = data.map do |item|
                  guids = Array(item["Guid"])
                  item["imdb_id"] = Plex::GuidHelper.extract(guids, "imdb")
                  item["tmdb_id"] = Plex::GuidHelper.extract(guids, "tmdb")
                  item["tvdb_id"] = Plex::GuidHelper.extract(guids, "tvdb")
                  item.delete("Guid")  # Remove nested array to keep output flat
                  item
                end
              end
              
              Plex::Output.ndjson(data)
            else
              Plex::Output.emit(body, raw: opts[:raw])
            end
          end
        end

        # ── filters ───────────────────────────────────────────────────────────
        lib.desc "GET /library/sections/{key}/filters|sorts — Discover valid filter keys and sort values"
        lib.command :filters do |c|
          c.flag "section-key", desc: "Section key", required: true, type: Integer
          c.flag :what, desc: "filters (default), sorts, categories, or first-characters",
                        default_value: "filters"
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            endpoint = case opts[:what]
            when "filters"           then "filters"
            when "sorts"             then "sorts"
            when "categories"        then "categories"
            when "first-characters"  then "firstCharacter"
            else
              $stderr.puts "Error: --what must be filters, sorts, categories, or first-characters"
              exit 1
            end
            body = g[:client].get("/library/sections/#{opts["section-key"]}/#{endpoint}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── refresh ───────────────────────────────────────────────────────────
        lib.desc "POST /library/sections/{key}/refresh — Trigger a section re-scan"
        lib.command :refresh do |c|
          c.flag "section-key", desc: "Section key", required: true, type: Integer
          c.switch :force, desc: "Force full re-scan even if nothing appears changed", negatable: false
          c.action do |g, opts, _|
            params = opts[:force] ? { force: 1 } : {}
            body = g[:client].post("/library/sections/#{opts["section-key"]}/refresh", params)
            Plex::Output.emit(body)
          end
        end

        # ── analyze ───────────────────────────────────────────────────────────
        lib.desc "PUT /library/sections/{key}/analyze — Deep media analysis for an entire section"
        lib.command :analyze do |c|
          c.flag "section-key", desc: "Section key", required: true, type: Integer
          c.action do |g, opts, _|
            body = g[:client].put("/library/sections/#{opts["section-key"]}/analyze")
            Plex::Output.emit(body)
          end
        end

        # ── empty-trash ───────────────────────────────────────────────────────
        lib.desc "PUT /library/sections/{key}/emptyTrash — Permanently delete trashed items in a section"
        lib.command "empty-trash" do |c|
          c.flag "section-key", desc: "Section key", required: true, type: Integer
          c.action do |g, opts, _|
            body = g[:client].put("/library/sections/#{opts["section-key"]}/emptyTrash")
            Plex::Output.emit(body)
          end
        end

      end
    end
  end
end
