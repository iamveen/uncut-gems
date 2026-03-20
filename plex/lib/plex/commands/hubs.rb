module Plex
  module Commands
    def self.register_hubs(prog)
      prog.desc "Home screen hubs (Continue Watching, On Deck, Recently Added, etc.)"
      prog.command :hubs do |hubs|

        # ── list ──────────────────────────────────────────────────────────────
        hubs.desc "GET /hubs — All home screen hubs across the server (NDJSON, one hub per line)"
        hubs.command :list do |c|
          c.flag :count,       desc: "Max items per hub (default 10)", type: Integer
          c.flag :scope,       desc: "home (default), promoted, continue-watching, section, metadata",
                               default_value: "home"
          c.flag "section-key", desc: "Required for scope=section", type: Integer
          c.flag "rating-key",  desc: "Required for scope=metadata"
          c.switch :raw,        desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            params = opts[:count] ? { count: opts[:count] } : {}
            path = case opts[:scope]
            when "home"             then "/hubs"
            when "promoted"         then "/hubs/promoted"
            when "continue-watching" then "/hubs/continueWatching"
            when "section"
              unless opts["section-key"]
                $stderr.puts "Error: --section-key required for scope=section"
                exit 1
              end
              "/hubs/sections/#{opts["section-key"]}"
            when "metadata"
              unless opts["rating-key"]
                $stderr.puts "Error: --rating-key required for scope=metadata"
                exit 1
              end
              "/hubs/metadata/#{opts["rating-key"]}"
            else
              $stderr.puts "Error: unknown scope '#{opts[:scope]}'"
              exit 1
            end
            body = g[:client].get(path, params)
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── on-deck ───────────────────────────────────────────────────────────
        hubs.desc "GET /library/onDeck — Items currently in progress (On Deck) across all libraries (NDJSON)"
        hubs.command "on-deck" do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/library/onDeck")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── recently-added ────────────────────────────────────────────────────
        hubs.desc "GET /library/recentlyAdded — Recently added items across all libraries (NDJSON)"
        hubs.command "recently-added" do |c|
          c.flag "section-key", desc: "Limit to a specific section", type: Integer
          c.flag :limit,        desc: "Max items to return (default 50)", type: Integer, default_value: 50
          c.switch :raw,        desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            params = { "X-Plex-Container-Size": opts[:limit] }
            path = opts["section-key"] \
              ? "/library/sections/#{opts["section-key"]}/recentlyAdded" \
              : "/library/recentlyAdded"
            body = g[:client].get(path, params)
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── postplay ──────────────────────────────────────────────────────────
        hubs.desc "GET /hubs/metadata/{ratingKey}/postplay — What to play next after a given item (Up Next)"
        hubs.command :postplay do |c|
          c.flag "rating-key", desc: "ratingKey of the item that just finished", required: true
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/hubs/metadata/#{opts["rating-key"]}/postplay")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

      end
    end
  end
end
