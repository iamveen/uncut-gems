module Hdbits
  module Commands
    def self.register_top(prog)
      prog.desc "Top-50 charts for films and TV shows"
      prog.command :top do |top|

        # ── films ─────────────────────────────────────────────────────────────
        top.desc "Top 50 films for a given time period (NDJSON). POST /api/topFilm."
        top.command :films do |c|
          c.flag :list, desc: "Time period: FilmNewThisWeek | FilmNewThisMonth | FilmNewLastMonth | FilmNewThisYear",
                        required: true
          c.action do |g, opts, _|
            body = g[:client].post("/topFilm", list: opts[:list])
            Hdbits::Output.ndjson(body["data"])
          end
        end

        # ── tv ────────────────────────────────────────────────────────────────
        top.desc "Top 50 TV shows for a given time period (NDJSON). POST /api/topTV."
        top.command :tv do |c|
          c.flag :list, desc: "Time period: TVNewThisWeek | TVNewThisMonth | TVTopThisWeek | TVNewThisSeason | TVNewLastSeason",
                        required: true
          c.action do |g, opts, _|
            body = g[:client].post("/topTV", list: opts[:list])
            Hdbits::Output.ndjson(body["data"])
          end
        end

      end
    end
  end
end
