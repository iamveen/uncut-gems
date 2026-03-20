module Hdbits
  module Commands
    def self.register_subtitles(prog)
      prog.desc "Return subtitles linked to a torrent (NDJSON). POST /api/subtitles. " \
                "Download a subtitle at: https://hdbits.org/getdox.php?id=<id>&passkey=<passkey>"
      prog.command :subtitles do |c|
        c.flag "torrent-id", desc: "Torrent ID", required: true, type: Integer
        c.action do |g, opts, _|
          body = g[:client].post("/subtitles", torrent_id: opts["torrent-id"])
          Hdbits::Output.ndjson(body["data"])
        end
      end
    end
  end
end
