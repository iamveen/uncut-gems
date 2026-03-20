# frozen_string_literal: true

module Qbit
  module Commands
    def self.register_category(prog)
      prog.desc "Category management: list, create, edit, delete"
      prog.command :category do |cat|

        # ── list ───────────────────────────────────────────────────────────────
        cat.desc "GET /api/v2/torrents/categories — All categories (NDJSON). " \
                 "API returns a name→object map; CLI unwraps to NDJSON of the values."
        cat.command :list do |c|
          c.switch :raw, negatable: false, desc: "Return the raw name→object map as JSON"
          c.action do |g, opts, _|
            body = g[:client].get("/torrents/categories")
            if opts[:raw]
              Qbit::Output.pretty(body)
            else
              Qbit::Output.ndjson(body.values) if body.is_a?(Hash)
            end
          end
        end

        # ── create ─────────────────────────────────────────────────────────────
        cat.desc "POST /api/v2/torrents/createCategory — Create a new category"
        cat.command :create do |c|
          c.flag :name,      desc: "Category name (required)", required: true
          c.flag "save-path", desc: "Default save path (optional; leave blank for global default)"
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/createCategory",
              category: opts[:name],
              savePath: opts["save-path"] || ""
            )
            Qbit::Output.json(body)
          end
        end

        # ── edit ───────────────────────────────────────────────────────────────
        cat.desc "POST /api/v2/torrents/editCategory — Edit an existing category's save path"
        cat.command :edit do |c|
          c.flag :name,      desc: "Category name to edit (required)", required: true
          c.flag "save-path", desc: "New save path (required)", required: true
          c.action do |g, opts, _|
            body = g[:client].post("/torrents/editCategory",
              category: opts[:name],
              savePath: opts["save-path"]
            )
            Qbit::Output.json(body)
          end
        end

        # ── delete ─────────────────────────────────────────────────────────────
        cat.desc "POST /api/v2/torrents/removeCategories — Delete one or more categories. " \
                 "Affected torrents become uncategorised; files are not moved."
        cat.command :delete do |c|
          c.flag :names, desc: "Comma-separated category names to delete (required)", required: true
          c.action do |g, opts, _|
            # API expects newline-separated names
            categories = opts[:names].split(",").map(&:strip).join("\n")
            body = g[:client].post("/torrents/removeCategories", categories: categories)
            Qbit::Output.json(body)
          end
        end

      end
    end
  end
end
