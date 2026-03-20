module Plex
  module Commands
    def self.register_playlists(prog)
      prog.desc "Playlists: list, get, create, update, delete, and manage items"
      prog.command :playlists do |pl|

        # ── list ──────────────────────────────────────────────────────────────
        pl.desc "GET /playlists — All playlists (NDJSON)"
        pl.command :list do |c|
          c.flag :type, desc: "Filter by type: video, audio, or photo"
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            params = { playlistType: opts[:type] }.compact
            body = g[:client].get("/playlists", params)
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── get ───────────────────────────────────────────────────────────────
        pl.desc "GET /playlists/{key} — Single playlist details"
        pl.command :get do |c|
          c.flag :key, desc: "Playlist key (ratingKey)", required: true
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/playlists/#{opts[:key]}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── create ────────────────────────────────────────────────────────────
        pl.desc "POST /playlists — Create a new playlist"
        pl.command :create do |c|
          c.flag :title, desc: "Playlist title", required: true
          c.flag :type,  desc: "Playlist type: video, audio, or photo", required: true
          c.flag :uri,   desc: "Library URI to pre-populate (optional)"
          c.switch :smart, desc: "Create a smart playlist", negatable: false
          c.action do |g, opts, _|
            params = {
              title: opts[:title],
              type:  opts[:type],
              smart: opts[:smart] ? 1 : 0,
              uri:   opts[:uri],
            }.compact
            body = g[:client].post("/playlists", params)
            Plex::Output.emit(body)
          end
        end

        # ── update ────────────────────────────────────────────────────────────
        pl.desc "PUT /playlists/{key} — Update a playlist's title or summary"
        pl.command :update do |c|
          c.flag :key,     desc: "Playlist key", required: true
          c.flag :title,   desc: "New title"
          c.flag :summary, desc: "New summary"
          c.action do |g, opts, _|
            params = { title: opts[:title], summary: opts[:summary] }.compact
            body = g[:client].put("/playlists/#{opts[:key]}", params)
            Plex::Output.emit(body)
          end
        end

        # ── delete ────────────────────────────────────────────────────────────
        pl.desc "DELETE /playlists/{key} — Delete a playlist"
        pl.command :delete do |c|
          c.flag :key, desc: "Playlist key", required: true
          c.action do |g, opts, _|
            body = g[:client].delete("/playlists/#{opts[:key]}")
            Plex::Output.emit(body)
          end
        end

        # ── items ─────────────────────────────────────────────────────────────
        pl.desc "GET /playlists/{key}/items — Ordered item list (NDJSON). " \
                "Each item has a playlistItemID (used for move/remove, not ratingKey)."
        pl.command :items do |c|
          c.flag :key, desc: "Playlist key", required: true
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/playlists/#{opts[:key]}/items")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── add-items ─────────────────────────────────────────────────────────
        pl.desc "PUT /playlists/{key}/items — Add items to a playlist by ratingKey"
        pl.command "add-items" do |c|
          c.flag :key,          desc: "Playlist key", required: true
          c.flag "rating-keys", desc: "Comma-separated ratingKeys to add", required: true
          c.action do |g, opts, _|
            keys = opts["rating-keys"].split(",").map(&:strip)
            uri  = keys.map { |k| "library://metadata/#{k}" }.join(",")
            body = g[:client].put("/playlists/#{opts[:key]}/items", { uri: uri })
            Plex::Output.emit(body)
          end
        end

        # ── remove-items ──────────────────────────────────────────────────────
        pl.desc "DELETE /playlists/{key}/items — Remove items from a playlist by playlistItemID"
        pl.command "remove-items" do |c|
          c.flag :key,               desc: "Playlist key", required: true
          c.flag "playlist-item-ids", desc: "Comma-separated playlistItemIDs to remove", required: true
          c.action do |g, opts, _|
            ids  = opts["playlist-item-ids"].split(",").map(&:strip).join(",")
            body = g[:client].delete("/playlists/#{opts[:key]}/items", { itemID: ids })
            Plex::Output.emit(body)
          end
        end

        # ── move-item ─────────────────────────────────────────────────────────
        pl.desc "PUT /playlists/{key}/items/{playlistItemID}/move — Reorder an item in a playlist"
        pl.command "move-item" do |c|
          c.flag :key,                desc: "Playlist key", required: true
          c.flag "playlist-item-id",  desc: "playlistItemID of the item to move", required: true
          c.flag :after,              desc: "Insert after this playlistItemID (omit to move to top)"
          c.action do |g, opts, _|
            params = opts[:after] ? { after: opts[:after] } : {}
            body = g[:client].put(
              "/playlists/#{opts[:key]}/items/#{opts["playlist-item-id"]}/move",
              params
            )
            Plex::Output.emit(body)
          end
        end

      end
    end
  end
end
