module Plex
  module Commands
    def self.register_metadata(prog)
      prog.desc "Item metadata: get, update, children, related, actions (refresh/analyze/merge/etc.)"
      prog.command :metadata do |meta|

        # ── get ───────────────────────────────────────────────────────────────
        meta.desc "GET /library/metadata/{ratingKey} — Full metadata record for any item"
        meta.command :get do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/library/metadata/#{opts["rating-key"]}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── update ────────────────────────────────────────────────────────────
        meta.desc "PUT /library/metadata/{ratingKey} — Write metadata fields back to an item"
        meta.command :update do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.flag :set, desc: "Field to update as KEY=VALUE (repeatable). " \
                             "Editable fields: title, originalTitle, summary, tagline, " \
                             "contentRating, rating, year, originallyAvailableAt, studio",
                       multiple: true
          c.action do |g, opts, _|
            if opts[:set].empty?
              $stderr.puts "Error: provide at least one --set KEY=VALUE"
              exit 1
            end
            params = opts[:set].each_with_object({}) do |pair, h|
              k, v = pair.split("=", 2)
              h[k] = v
            end
            body = g[:client].put("/library/metadata/#{opts["rating-key"]}", params)
            Plex::Output.emit(body)
          end
        end

        # ── children ──────────────────────────────────────────────────────────
        meta.desc "GET /library/metadata/{ratingKey}/children — Direct children of a container item " \
                  "(show→seasons, season→episodes, artist→albums, album→tracks). NDJSON."
        meta.command :children do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.switch "all-leaves", desc: "Jump straight to leaf items (episodes/tracks)", negatable: false
          c.switch :raw,         desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            suffix = opts["all-leaves"] ? "allLeaves" : "children"
            body = g[:client].get("/library/metadata/#{opts["rating-key"]}/#{suffix}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── related ───────────────────────────────────────────────────────────
        meta.desc "GET /library/metadata/{ratingKey}/related — Hub rows of related content for an item"
        meta.command :related do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.switch :similar, desc: "Use /similar endpoint instead of /related", negatable: false
          c.switch :raw,     desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            suffix = opts[:similar] ? "similar" : "related"
            body = g[:client].get("/library/metadata/#{opts["rating-key"]}/#{suffix}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── refresh ───────────────────────────────────────────────────────────
        meta.desc "PUT /library/metadata/{ratingKey}/refresh — Re-fetch metadata from the agent"
        meta.command :refresh do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.switch :force, desc: "Force re-download even if not stale", negatable: false
          c.action do |g, opts, _|
            params = opts[:force] ? { force: 1 } : {}
            body = g[:client].put("/library/metadata/#{opts["rating-key"]}/refresh", params)
            Plex::Output.emit(body)
          end
        end

        # ── analyze ───────────────────────────────────────────────────────────
        meta.desc "PUT /library/metadata/{ratingKey}/analyze — Deep media analysis (re-detect streams, intros, credits)"
        meta.command :analyze do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.action do |g, opts, _|
            body = g[:client].put("/library/metadata/#{opts["rating-key"]}/analyze")
            Plex::Output.emit(body)
          end
        end

        # ── unmatch ───────────────────────────────────────────────────────────
        meta.desc "PUT /library/metadata/{ratingKey}/unmatch — Detach from current agent match so it will be re-matched"
        meta.command :unmatch do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.action do |g, opts, _|
            body = g[:client].put("/library/metadata/#{opts["rating-key"]}/unmatch")
            Plex::Output.emit(body)
          end
        end

        # ── match ─────────────────────────────────────────────────────────────
        meta.desc "Search for agent matches or apply one. Two-step flow for fixing a mismatch."
        meta.command :match do |c|
          c.desc "search  — list candidate matches from the agent (default)\n" \
                 "apply   — lock the item to a chosen match (requires --guid)"
          c.arg :action, :optional
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.flag :title,       desc: "Override title for agent search"
          c.flag :year,        desc: "Override year for agent search", type: Integer
          c.flag :guid,        desc: "Agent GUID to match to (required for apply)"
          c.flag :name,        desc: "Display name of the match (for apply)"
          c.switch :raw,       desc: "Return full API envelope", negatable: false
          c.action do |g, opts, args|
            action = args.first || "search"
            rk = opts["rating-key"]
            case action
            when "search"
              params = { title: opts[:title], year: opts[:year] }.compact
              body = g[:client].get("/library/metadata/#{rk}/matches", params)
              Plex::Output.emit(body, raw: opts[:raw])
            when "apply"
              unless opts[:guid]
                $stderr.puts "Error: --guid required for apply"
                exit 1
              end
              params = { guid: opts[:guid], name: opts[:name], year: opts[:year] }.compact
              body = g[:client].put("/library/metadata/#{rk}/match", params)
              Plex::Output.emit(body, raw: opts[:raw])
            else
              $stderr.puts "Error: unknown action '#{action}'"
              exit 1
            end
          end
        end

        # ── merge ─────────────────────────────────────────────────────────────
        meta.desc "PUT /library/metadata/{ratingKey}/merge — Merge other items into this one"
        meta.command :merge do |c|
          c.flag "rating-key", desc: "Target item ID (ratingKey)", required: true
          c.flag :ids,         desc: "Comma-separated ratingKeys to merge in", required: true
          c.action do |g, opts, _|
            body = g[:client].put("/library/metadata/#{opts["rating-key"]}/merge", { ids: opts[:ids] })
            Plex::Output.emit(body)
          end
        end

        # ── split ─────────────────────────────────────────────────────────────
        meta.desc "PUT /library/metadata/{ratingKey}/split — Split a merged item back into its components"
        meta.command :split do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.action do |g, opts, _|
            body = g[:client].put("/library/metadata/#{opts["rating-key"]}/split")
            Plex::Output.emit(body)
          end
        end

      end
    end
  end
end
