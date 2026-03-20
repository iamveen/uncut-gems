module Plex
  module Commands
    def self.register_dvr(prog)
      prog.desc "DVR configurations, recording subscriptions, and Live TV channel guide"
      prog.command :dvr do |dvr|

        # ── list ──────────────────────────────────────────────────────────────
        dvr.desc "GET /livetv/dvrs — All configured DVR pairings (tuner + guide lineup). NDJSON."
        dvr.command :list do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/livetv/dvrs")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── channels ──────────────────────────────────────────────────────────
        dvr.desc "GET /livetv/epg/channels — Full EPG channel list (NDJSON)"
        dvr.command :channels do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/livetv/epg/channels")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── tune ──────────────────────────────────────────────────────────────
        dvr.desc "POST /livetv/dvrs/{dvrID}/channels/{channelNumber}/tune — Tune to a live channel"
        dvr.command :tune do |c|
          c.flag "dvr-id",         desc: "DVR ID from 'dvr list'", required: true
          c.flag "channel-number", desc: "Channel number or callSign", required: true
          c.action do |g, opts, _|
            body = g[:client].post(
              "/livetv/dvrs/#{opts["dvr-id"]}/channels/#{opts["channel-number"]}/tune"
            )
            Plex::Output.emit(body)
          end
        end

        # ── reload-guide ──────────────────────────────────────────────────────
        dvr.desc "POST /livetv/dvrs/{dvrID}/reloadGuide — Refresh EPG data for a DVR"
        dvr.command "reload-guide" do |c|
          c.flag "dvr-id", desc: "DVR ID from 'dvr list'", required: true
          c.action do |g, opts, _|
            body = g[:client].post("/livetv/dvrs/#{opts["dvr-id"]}/reloadGuide")
            Plex::Output.emit(body)
          end
        end

        # ── subscriptions ─────────────────────────────────────────────────────
        dvr.desc "Manage DVR auto-record subscriptions"
        dvr.command :subscriptions do |sub|

          sub.desc "GET /media/subscriptions — All auto-record rules (NDJSON)"
          sub.command :list do |c|
            c.switch :raw, desc: "Return full API envelope", negatable: false
            c.action do |g, opts, _|
              body = g[:client].get("/media/subscriptions")
              Plex::Output.emit(body, raw: opts[:raw])
            end
          end

          sub.desc "GET /media/subscriptions/scheduled — Upcoming scheduled recordings (NDJSON)"
          sub.command :scheduled do |c|
            c.switch :raw, desc: "Return full API envelope", negatable: false
            c.action do |g, opts, _|
              body = g[:client].get("/media/subscriptions/scheduled")
              Plex::Output.emit(body, raw: opts[:raw])
            end
          end

          sub.desc "POST /media/subscriptions — Create an auto-record rule"
          sub.command :create do |c|
            c.flag "metadata-id",       desc: "ratingKey of the show/event to record", required: true
            c.flag "pre-padding",       desc: "Pre-recording padding in seconds", type: Integer
            c.flag "post-padding",      desc: "Post-recording padding in seconds", type: Integer
            c.flag "episode-range",     desc: "all or new (default new)", default_value: "new"
            c.flag "target-section-id", desc: "Target library section ID", type: Integer
            c.action do |g, opts, _|
              params = {
                metadataID:      opts["metadata-id"],
                prePaddingSeconds:  opts["pre-padding"],
                postPaddingSeconds: opts["post-padding"],
                episodeRange:    opts["episode-range"],
                targetSectionID: opts["target-section-id"],
              }.compact
              body = g[:client].post("/media/subscriptions", params)
              Plex::Output.emit(body)
            end
          end

          sub.desc "DELETE /media/subscriptions/{id} — Delete a subscription"
          sub.command :delete do |c|
            c.flag :id, desc: "Subscription ID", required: true
            c.action do |g, opts, _|
              body = g[:client].delete("/media/subscriptions/#{opts[:id]}")
              Plex::Output.emit(body)
            end
          end

        end

      end
    end
  end
end
