module Plex
  module Commands
    def self.register_sessions(prog)
      prog.desc "Active playback sessions: list and terminate"
      prog.command :sessions do |sess|

        # ── list ──────────────────────────────────────────────────────────────
        sess.desc "GET /status/sessions — All active playback sessions (NDJSON). " \
                  "Each session includes sessionKey (needed for terminate), User, Player, " \
                  "TranscodeSession, and viewOffset."
        sess.command :list do |c|
          c.switch :background, desc: "Return background sessions instead of active user sessions",
                                negatable: false
          c.switch :raw,        desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            path = opts[:background] ? "/status/sessions/background" : "/status/sessions"
            body = g[:client].get(path)
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── terminate ─────────────────────────────────────────────────────────
        sess.desc "GET /status/sessions/terminate — Force-kill an active playback session"
        sess.command :terminate do |c|
          c.flag "session-key", desc: "Session key from 'sessions list'", required: true
          c.flag :reason,       desc: "Message shown to the user e.g. 'Server maintenance in 5 min'"
          c.action do |g, opts, _|
            params = {
              sessionKey: opts["session-key"],
              reason:     opts[:reason],
            }.compact
            body = g[:client].get("/status/sessions/terminate", params)
            Plex::Output.emit(body)
          end
        end

      end
    end
  end
end
