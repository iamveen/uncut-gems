# frozen_string_literal: true

module Qbit
  module Commands
    def self.register_tag(prog)
      prog.desc "Tag management: list, create, delete. Tags are referenced by name in torrent records."
      prog.command :tag do |t|

        # ── list ───────────────────────────────────────────────────────────────
        t.desc "GET /api/v2/torrents/tags — All tags (NDJSON). " \
               "API returns a JSON array of strings; CLI wraps each in {\"name\":\"...\"}."
        t.command :list do |c|
          c.switch :raw, negatable: false, desc: "Return the raw JSON array of strings"
          c.action do |g, opts, _|
            body = g[:client].get("/torrents/tags")
            if opts[:raw]
              Qbit::Output.pretty(body)
            else
              Qbit::Output.ndjson(Array(body).map { |name| { "name" => name } })
            end
          end
        end

        # ── create ─────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/createTags — Create one or more tags globally. " \
               "Tags must exist globally before they can be assigned to torrents."
        t.command :create do |c|
          c.flag :tags, desc: "Comma-separated tag names to create (required)", required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/createTags", tags: Qbit::Output.tags_param(opts[:tags]))
            Qbit::Output.json(body)
          end
        end

        # ── delete ─────────────────────────────────────────────────────────────
        t.desc "POST /api/v2/torrents/deleteTags — Delete one or more tags globally. " \
               "Also removes the tag from all torrents that had it assigned."
        t.command :delete do |c|
          c.flag :tags, desc: "Comma-separated tag names to delete (required)", required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/deleteTags", tags: Qbit::Output.tags_param(opts[:tags]))
            Qbit::Output.json(body)
          end
        end

      end
    end
  end
end
