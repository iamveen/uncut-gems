module Plex
  module Commands
    def self.register_search(prog)
      prog.desc "GET /hubs/search — Full-text search across all libraries. " \
                "Returns NDJSON with one result per line, each annotated with a _hub field."
      prog.command :search do |c|
        c.flag :query,      desc: "Search terms", required: true
        c.flag :limit,      desc: "Max results per hub (default 10)", type: Integer, default_value: 10
        c.flag "media-type", desc: "Restrict to media type integer: 1=movie 2=show 4=episode 8=artist 9=album 10=track",
                              type: Integer
        c.switch :voice, desc: "Use voice/fuzzy search endpoint", negatable: false
        c.switch :raw,   desc: "Return full API envelope", negatable: false
        c.action do |g, opts, _|
          endpoint = opts[:voice] ? "/hubs/search/voice" : "/hubs/search"
          params = {
            query:     opts[:query],
            limit:     opts[:limit],
            mediaType: opts["media-type"],
          }.compact
          body = g[:client].get(endpoint, params)

          if opts[:raw]
            Plex::Output.pretty(body)
            next
          end

          # Flatten hubs into NDJSON, annotating each item with its hub title.
          hubs = body.dig("MediaContainer", "Hub") || []
          hubs.each do |hub|
            hub_title = hub["title"]
            (hub["Metadata"] || []).each do |item|
              item["_hub"] = hub_title
              puts JSON.generate(item)
            end
          end
        end
      end
    end
  end
end
