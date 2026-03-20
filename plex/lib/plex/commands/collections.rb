module Plex
  module Commands
    def self.register_collections(prog)
      prog.desc "Collections: list, get, manage items (NDJSON for lists)"
      prog.command :collections do |col|

        # ── list ──────────────────────────────────────────────────────────────
        col.desc "GET /library/sections/{sectionKey}/collections — All collections in a section (NDJSON)"
        col.command :list do |c|
          c.flag "section-key", desc: "Section key (from 'library list')", required: true, type: Integer
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/library/sections/#{opts["section-key"]}/collections")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── get ───────────────────────────────────────────────────────────────
        col.desc "GET /library/collections/{collectionKey} — Single collection metadata"
        col.command :get do |c|
          c.flag "collection-key", desc: "Collection ratingKey", required: true
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/library/collections/#{opts["collection-key"]}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── items ─────────────────────────────────────────────────────────────
        col.desc "GET /library/collections/{collectionKey}/children — Items inside a collection (NDJSON)"
        col.command :items do |c|
          c.flag "collection-key", desc: "Collection ratingKey", required: true
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/library/collections/#{opts["collection-key"]}/children")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── add-items ─────────────────────────────────────────────────────────
        col.desc "PUT /library/collections/{collectionKey}/items — Add items to a collection"
        col.command "add-items" do |c|
          c.flag "collection-key", desc: "Collection ratingKey", required: true
          c.flag "rating-keys",    desc: "Comma-separated ratingKeys to add", required: true
          c.action do |g, opts, _|
            keys = opts["rating-keys"].split(",").map(&:strip)
            uri  = keys.map { |k| "library://metadata/#{k}" }.join(",")
            body = g[:client].put("/library/collections/#{opts["collection-key"]}/items", { uri: uri })
            Plex::Output.emit(body)
          end
        end

        # ── move-item ─────────────────────────────────────────────────────────
        col.desc "PUT /library/collections/{collectionKey}/items/{itemKey}/move — Reorder an item"
        col.command "move-item" do |c|
          c.flag "collection-key", desc: "Collection ratingKey", required: true
          c.flag "item-key",       desc: "ratingKey of item to move", required: true
          c.flag :after,           desc: "Insert after this item's ratingKey (omit to move to top)"
          c.action do |g, opts, _|
            params = opts[:after] ? { after: opts[:after] } : {}
            body = g[:client].put(
              "/library/collections/#{opts["collection-key"]}/items/#{opts["item-key"]}/move",
              params
            )
            Plex::Output.emit(body)
          end
        end

        # ── delete ────────────────────────────────────────────────────────────
        col.desc "DELETE /library/sections/{sectionKey}/collections/{collectionKey} — Delete a collection"
        col.command :delete do |c|
          c.flag "section-key",    desc: "Section key", required: true, type: Integer
          c.flag "collection-key", desc: "Collection ratingKey", required: true
          c.action do |g, opts, _|
            body = g[:client].delete(
              "/library/sections/#{opts["section-key"]}/collections/#{opts["collection-key"]}"
            )
            Plex::Output.emit(body)
          end
        end

      end
    end
  end
end
