module Hdbits
  module Commands
    def self.register_user(prog)
      prog.desc "Return information about the authenticated user (pretty JSON). POST /api/user."
      prog.command :user do |c|
        c.action do |g, _opts, _|
          body = g[:client].post("/user")
          Hdbits::Output.pretty(body["data"])
        end
      end
    end
  end
end
