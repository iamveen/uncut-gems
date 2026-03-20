module Hdbits
  module Commands
    def self.register_wishlist(prog)
      prog.desc "Manage the authenticated user's wishlist"
      prog.command :wishlist do |wl|

        # ── list ──────────────────────────────────────────────────────────────
        wl.desc "Return the user's wishlist (NDJSON). POST /api/wishlist."
        wl.command :list do |c|
          c.action do |g, _opts, _|
            body = g[:client].post("/wishlist")
            Hdbits::Output.ndjson(body["data"])
          end
        end

        # ── add ───────────────────────────────────────────────────────────────
        wl.desc "Add a film to the wishlist by IMDb numeric ID. POST /api/wishlistAdd."
        wl.command :add do |c|
          c.flag "imdb-id", desc: "Numeric IMDb ID (e.g. 133093)", required: true, type: Integer
          c.action do |g, opts, _|
            g[:client].post("/wishlistAdd", imdb_id: opts["imdb-id"])
            # No response data on success — client already checked status == 0.
          end
        end

        # ── del ───────────────────────────────────────────────────────────────
        wl.desc "Remove an item from the wishlist by its wishlist item ID. POST /api/wishlistDel."
        wl.command :del do |c|
          c.flag :id, desc: "Wishlist item ID (from 'wishlist list')", required: true, type: Integer
          c.action do |g, opts, _|
            g[:client].post("/wishlistDel", id: opts[:id])
            # No response data on success.
          end
        end

      end
    end
  end
end
