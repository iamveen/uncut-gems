module TMDB
  module Commands
    def self.register_person(prog)
      prog.desc "Person operations - get details about actors, directors, and crew"
      prog.command :person do |c|
        # ── person details ─────────────────────────────────────────────────────
        c.desc "Get detailed information about a person. Returns JSON object."
        c.command :details do |details|
          details.flag :id, desc: "Person ID", type: Integer, required: true
          details.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          details.flag "append-to-response", desc: "Comma-separated list of sub-endpoints (movie_credits,tv_credits,images,etc)"
          details.switch :raw, desc: "Return full API envelope", negatable: false

          details.action do |g, opts, _|
            params = {
              language: opts[:language],
              append_to_response: opts["append-to-response"]
            }
            body = g[:client].get("/person/#{opts[:id]}", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── person movie-credits ───────────────────────────────────────────────
        c.desc "Get movie credits for a person (cast and crew). Returns JSON with cast and crew arrays."
        c.command "movie-credits" do |credits|
          credits.flag :id, desc: "Person ID", type: Integer, required: true
          credits.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          credits.switch :raw, desc: "Return full API envelope", negatable: false

          credits.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/person/#{opts[:id]}/movie_credits", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── person tv-credits ──────────────────────────────────────────────────
        c.desc "Get TV credits for a person (cast and crew). Returns JSON with cast and crew arrays."
        c.command "tv-credits" do |credits|
          credits.flag :id, desc: "Person ID", type: Integer, required: true
          credits.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          credits.switch :raw, desc: "Return full API envelope", negatable: false

          credits.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/person/#{opts[:id]}/tv_credits", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── person combined-credits ────────────────────────────────────────────
        c.desc "Get combined movie and TV credits for a person. Returns JSON with cast and crew arrays."
        c.command "combined-credits" do |credits|
          credits.flag :id, desc: "Person ID", type: Integer, required: true
          credits.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          credits.switch :raw, desc: "Return full API envelope", negatable: false

          credits.action do |g, opts, _|
            params = { language: opts[:language] }
            body = g[:client].get("/person/#{opts[:id]}/combined_credits", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── person images ──────────────────────────────────────────────────────
        c.desc "Get profile images for a person. Returns JSON with profiles array."
        c.command :images do |images|
          images.flag :id, desc: "Person ID", type: Integer, required: true
          images.switch :raw, desc: "Return full API envelope", negatable: false

          images.action do |g, opts, _|
            body = g[:client].get("/person/#{opts[:id]}/images", {})
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── person popular ─────────────────────────────────────────────────────
        c.desc "Get popular people. Returns NDJSON."
        c.command :popular do |popular|
          popular.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
          popular.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
          popular.switch :raw, desc: "Return full API envelope", negatable: false

          popular.action do |g, opts, _|
            params = {
              page: opts[:page],
              language: opts[:language]
            }
            body = g[:client].get("/person/popular", params)
            TMDB::Output.emit(body, raw: opts[:raw])
          end
        end
      end
    end
  end
end
