module Hdbits
  module Commands
    def self.register_tags(prog)
      prog.desc "Return all tags defined on the site (NDJSON). POST /api/tags."
      prog.command :tags do |c|
        c.action do |g, _opts, _|
          body = g[:client].post("/tags")
          Hdbits::Output.ndjson(body["data"])
        end
      end
    end
  end
end
