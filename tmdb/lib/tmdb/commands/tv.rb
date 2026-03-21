module TMDB
  module Commands
    def self.register_tv(prog)
      prog.desc "TV show operations - get details, credits, images, seasons, and episodes"
      prog.command :tv do |c|
        # ── tv details ─────────────────────────────────────────────────────────
        c.desc "Get detailed information about a TV show. Returns JSON object."
        c.command :details do |details|
          details.flag :id, desc: "TV show ID", type: Integer, required: true
          details.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          details.flag "append-to-response", desc: "Comma-separated list of sub-endpoints (credits,images,videos,etc)"
          details.switch :raw, desc: "Return full API envelope", negatable: false

          details.action do |g, opts, _|
            params = {
              language: opts[:language],
              append_to_response: opts["append-to-response"]
            }
            body = g[:client].get("/tv/#{opts[:id]}", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv credits ─────────────────────────────────────────────────────────
        c.desc "Get cast and crew credits for a TV show. Returns JSON with cast and crew arrays."
        c.command :credits do |credits|
          credits.flag :id, desc: "TV show ID", type: Integer, required: true
          credits.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          credits.switch :raw, desc: "Return full API envelope", negatable: false

          credits.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/tv/#{opts[:id]}/credits", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv images ──────────────────────────────────────────────────────────
        c.desc "Get images (posters, backdrops) for a TV show. Returns JSON with image arrays."
        c.command :images do |images|
          images.flag :id, desc: "TV show ID", type: Integer, required: true
          images.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          images.switch :raw, desc: "Return full API envelope", negatable: false

          images.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/tv/#{opts[:id]}/images", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv videos ──────────────────────────────────────────────────────────
        c.desc "Get videos (trailers, teasers) for a TV show. Returns JSON with video arrays."
        c.command :videos do |videos|
          videos.flag :id, desc: "TV show ID", type: Integer, required: true
          videos.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          videos.switch :raw, desc: "Return full API envelope", negatable: false

          videos.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/tv/#{opts[:id]}/videos", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv season ──────────────────────────────────────────────────────────
        c.desc "Get details about a TV season. Returns JSON object."
        c.command :season do |season|
          season.flag :id, desc: "TV show ID", type: Integer, required: true
          season.flag :season, desc: "Season number", type: Integer, required: true
          season.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          season.switch :raw, desc: "Return full API envelope", negatable: false

          season.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/tv/#{opts[:id]}/season/#{opts[:season]}", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv episode ─────────────────────────────────────────────────────────
        c.desc "Get details about a TV episode. Returns JSON object."
        c.command :episode do |episode|
          episode.flag :id, desc: "TV show ID", type: Integer, required: true
          episode.flag :season, desc: "Season number", type: Integer, required: true
          episode.flag :episode, desc: "Episode number", type: Integer, required: true
          episode.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          episode.switch :raw, desc: "Return full API envelope", negatable: false

          episode.action do |g, opts, _|
            params = { language: opts[:language] }
            path = "/tv/#{opts[:id]}/season/#{opts[:season]}/episode/#{opts[:episode]}"
            body = g[:client].get(path, params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv recommendations ─────────────────────────────────────────────────
        c.desc "Get TV show recommendations. Returns NDJSON."
        c.command :recommendations do |rec|
          rec.flag :id, desc: "TV show ID", type: Integer, required: true
          rec.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          rec.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          rec.switch :raw, desc: "Return full API envelope", negatable: false

          rec.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/tv/#{opts[:id]}/recommendations", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv similar ─────────────────────────────────────────────────────────
        c.desc "Get similar TV shows. Returns NDJSON."
        c.command :similar do |similar|
          similar.flag :id, desc: "TV show ID", type: Integer, required: true
          similar.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          similar.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          similar.switch :raw, desc: "Return full API envelope", negatable: false

          similar.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/tv/#{opts[:id]}/similar", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv popular ─────────────────────────────────────────────────────────
        c.desc "Get popular TV shows. Returns NDJSON."
        c.command :popular do |popular|
          popular.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          popular.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          popular.switch :raw, desc: "Return full API envelope", negatable: false

          popular.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/tv/popular", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv top-rated ───────────────────────────────────────────────────────
        c.desc "Get top-rated TV shows. Returns NDJSON."
        c.command "top-rated" do |top|
          top.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          top.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          top.switch :raw, desc: "Return full API envelope", negatable: false

          top.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/tv/top_rated", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv on-the-air ──────────────────────────────────────────────────────
        c.desc "Get TV shows currently on the air. Returns NDJSON."
        c.command "on-the-air" do |on_air|
          on_air.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          on_air.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          on_air.switch :raw, desc: "Return full API envelope", negatable: false

          on_air.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/tv/on_the_air", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tv airing-today ────────────────────────────────────────────────────
        c.desc "Get TV shows airing today. Returns NDJSON."
        c.command "airing-today" do |airing|
          airing.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          airing.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          airing.switch :raw, desc: "Return full API envelope", negatable: false

          airing.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/tv/airing_today", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end
      end
    end
  end
end
