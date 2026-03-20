module Hdbits
  module Commands
    def self.register_rss(prog)
      prog.desc "Add a torrent to the user's personal RSS feed. POST /api/rssAdd."
      prog.command "rss-add" do |c|
        c.flag "torrent-id", desc: "Torrent ID to add to RSS feed", required: true, type: Integer
        c.action do |g, opts, _|
          g[:client].post("/rssAdd", torrent_id: opts["torrent-id"])
          # No response data on success — client already checked status == 0.
        end
      end
    end
  end
end
