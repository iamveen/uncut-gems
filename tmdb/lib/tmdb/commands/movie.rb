module TMDB
  module Commands
    def self.register_movie(prog)
      prog.desc "Movie operations - get details, credits, images, and more"
      prog.command :movie do |c|
        # ── movie details ──────────────────────────────────────────────────────
        c.desc "Get detailed information about a movie. Returns JSON object."
        c.command :details do |details|
          details.flag :id, desc: "Movie ID", type: Integer, required: true
          details.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          details.flag "append-to-response", desc: "Comma-separated list of sub-endpoints (credits,images,videos,etc)"
          details.switch :raw, desc: "Return full API envelope", negatable: false

          details.action do |g, opts, _|
            params = {
              language: opts[:language],
              append_to_response: opts["append-to-response"]
            }
            body = g[:client].get("/movie/#{opts[:id]}", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie credits ──────────────────────────────────────────────────────
        c.desc "Get cast and crew credits for a movie. Returns JSON with cast and crew arrays."
        c.command :credits do |credits|
          credits.flag :id, desc: "Movie ID", type: Integer, required: true
          credits.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          credits.switch :raw, desc: "Return full API envelope", negatable: false

          credits.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/movie/#{opts[:id]}/credits", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie images ───────────────────────────────────────────────────────
        c.desc "Get images (posters, backdrops) for a movie. Returns JSON with image arrays."
        c.command :images do |images|
          images.flag :id, desc: "Movie ID", type: Integer, required: true
          images.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          images.switch :raw, desc: "Return full API envelope", negatable: false

          images.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/movie/#{opts[:id]}/images", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie videos ───────────────────────────────────────────────────────
        c.desc "Get videos (trailers, teasers) for a movie. Returns JSON with video arrays."
        c.command :videos do |videos|
          videos.flag :id, desc: "Movie ID", type: Integer, required: true
          videos.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          videos.switch :raw, desc: "Return full API envelope", negatable: false

          videos.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/movie/#{opts[:id]}/videos", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie recommendations ──────────────────────────────────────────────
        c.desc "Get movie recommendations based on a movie. Returns NDJSON."
        c.command :recommendations do |rec|
          rec.flag :id, desc: "Movie ID", type: Integer, required: true
          rec.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          rec.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          rec.switch :raw, desc: "Return full API envelope", negatable: false

          rec.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/movie/#{opts[:id]}/recommendations", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie similar ──────────────────────────────────────────────────────
        c.desc "Get similar movies. Returns NDJSON."
        c.command :similar do |similar|
          similar.flag :id, desc: "Movie ID", type: Integer, required: true
          similar.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          similar.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          similar.switch :raw, desc: "Return full API envelope", negatable: false

          similar.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/movie/#{opts[:id]}/similar", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie popular ──────────────────────────────────────────────────────
        c.desc "Get popular movies. Returns NDJSON."
        c.command :popular do |popular|
          popular.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          popular.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          popular.switch :raw, desc: "Return full API envelope", negatable: false

          popular.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/movie/popular", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie top-rated ────────────────────────────────────────────────────
        c.desc "Get top-rated movies. Returns NDJSON."
        c.command "top-rated" do |top|
          top.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          top.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          top.switch :raw, desc: "Return full API envelope", negatable: false

          top.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/movie/top_rated", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie now-playing ──────────────────────────────────────────────────
        c.desc "Get movies currently in theaters. Returns NDJSON."
        c.command "now-playing" do |now|
          now.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          now.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          now.flag :region, desc: "ISO 3166-1 code (e.g., US)"
          now.switch :raw, desc: "Return full API envelope", negatable: false

          now.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language],
              region: opts[:region]
            }
            body = g[:client].get("/movie/now_playing", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── movie upcoming ─────────────────────────────────────────────────────
        c.desc "Get upcoming movies. Returns NDJSON."
        c.command :upcoming do |upcoming|
          upcoming.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          upcoming.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          upcoming.flag :region, desc: "ISO 3166-1 code (e.g., US)"
          upcoming.switch :raw, desc: "Return full API envelope", negatable: false

          upcoming.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language],
              region: opts[:region]
            }
            body = g[:client].get("/movie/upcoming", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end
      end
    end
  end
end
