# frozen_string_literal: true

module Qbit
  module Commands
    def self.register_transfer(prog)
      prog.desc "Global transfer stats and speed limits"
      prog.command :transfer do |tr|

        # ── info ───────────────────────────────────────────────────────────────
        tr.desc "GET /api/v2/transfer/info — Live global transfer statistics (JSON). " \
                "Includes download/upload speeds, session totals, rate limits, and DHT node count."
        tr.command :info do |c|
          c.action do |g, _opts, _|
            body = g[:client].get("/transfer/info")
            Qbit::Output.pretty(body)
          end
        end

        # ── set-download-limit ─────────────────────────────────────────────────
        tr.desc "POST /api/v2/transfer/setDownloadLimit — Set global download speed cap. " \
                "Pass 0 to remove the limit."
        tr.command :"set-download-limit" do |c|
          c.flag "limit-bytes", desc: "Speed limit in bytes/s. 0 = unlimited. (required)",
                                required: true, type: Integer
          c.action do |g, opts, _|
            body = g[:client].post("/transfer/setDownloadLimit", limit: opts["limit-bytes"])
            Qbit::Output.json(body)
          end
        end

        # ── set-upload-limit ───────────────────────────────────────────────────
        tr.desc "POST /api/v2/transfer/setUploadLimit — Set global upload speed cap. " \
                "Pass 0 to remove the limit."
        tr.command :"set-upload-limit" do |c|
          c.flag "limit-bytes", desc: "Speed limit in bytes/s. 0 = unlimited. (required)",
                                required: true, type: Integer
          c.action do |g, opts, _|
            body = g[:client].post("/transfer/setUploadLimit", limit: opts["limit-bytes"])
            Qbit::Output.json(body)
          end
        end

        # ── toggle-speed-limits ────────────────────────────────────────────────
        tr.desc "POST /api/v2/transfer/toggleSpeedLimitsMode — Toggle alternative speed limits on/off. " \
                "This is a toggle: call once to enable, again to disable. " \
                "Alt limits are configured in qBittorrent Preferences → Speed."
        tr.command :"toggle-speed-limits" do |c|
          c.action do |g, _opts, _|
            body = g[:client].post("/transfer/toggleSpeedLimitsMode")
            Qbit::Output.json(body)
          end
        end

      end
    end
  end
end
