module Hdbits
  module Commands
    def self.register_test(prog)
      prog.desc "Test authentication credentials against POST /api/test. Exits 0 on success."
      prog.command :test do |c|
        c.action do |g, _opts, _|
          body = g[:client].post("/test")
          Hdbits::Output.pretty(body)
        end
      end
    end
  end
end
