module Plex
  module Commands
    def self.register_scrobble(prog)
      prog.desc "Mark items watched/unwatched and set star ratings"
      prog.command :scrobble do |scr|

        # ── watched ───────────────────────────────────────────────────────────
        scr.desc "GET /:/scrobble — Mark an item as fully watched (increments viewCount, removes from On Deck)"
        scr.command :watched do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.action do |g, opts, _|
            body = g[:client].get("/:/scrobble", {
              key:        opts["rating-key"],
              identifier: "com.plexapp.plugins.library",
            })
            Plex::Output.emit(body)
          end
        end

        # ── unwatched ─────────────────────────────────────────────────────────
        scr.desc "GET /:/unscrobble — Mark an item as unwatched (resets viewCount and viewOffset)"
        scr.command :unwatched do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.action do |g, opts, _|
            body = g[:client].get("/:/unscrobble", {
              key:        opts["rating-key"],
              identifier: "com.plexapp.plugins.library",
            })
            Plex::Output.emit(body)
          end
        end

        # ── rate ──────────────────────────────────────────────────────────────
        scr.desc "PUT /:/rate — Set a user star rating (0–10) on an item. Pass 0 to clear."
        scr.command :rate do |c|
          c.flag "rating-key", desc: "Item ID (ratingKey)", required: true
          c.flag :rating,      desc: "Rating from 0 (clear) to 10", required: true, type: Float
          c.action do |g, opts, _|
            body = g[:client].put("/:/rate", {
              key:        opts["rating-key"],
              identifier: "com.plexapp.plugins.library",
              rating:     opts[:rating],
            })
            Plex::Output.emit(body)
          end
        end

      end
    end
  end
end
