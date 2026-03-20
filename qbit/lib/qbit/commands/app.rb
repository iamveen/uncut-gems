# frozen_string_literal: true

module Qbit
  module Commands
    def self.register_app(prog)
      prog.desc "Application info, preferences, and session management"
      prog.command :app do |a|

        # ── version ────────────────────────────────────────────────────────────
        a.desc "GET /api/v2/app/version + /api/v2/app/apiVersion — App and API version (JSON)"
        a.command :version do |c|
          c.action do |g, _opts, _|
            app_version = g[:client].get("/app/version")
            api_version = g[:client].get("/app/apiVersion")
            # Both endpoints return plain strings, not JSON — the client wraps them
            app_str = app_version.is_a?(Hash) ? app_version["body"] : app_version.to_s.strip
            api_str = api_version.is_a?(Hash) ? api_version["body"] : api_version.to_s.strip
            Qbit::Output.pretty({ "app_version" => app_str, "api_version" => api_str })
          end
        end

        # ── preferences ────────────────────────────────────────────────────────
        a.desc "GET /api/v2/app/preferences — Full application preferences (JSON). " \
               "Field names vary by qBittorrent version. " \
               "Use this to discover the shape before writing with 'app set-preferences'."
        a.command :preferences do |c|
          c.action do |g, _opts, _|
            body = g[:client].get("/app/preferences")
            Qbit::Output.pretty(body)
          end
        end

        # ── set-preferences ────────────────────────────────────────────────────
        a.desc "POST /api/v2/app/setPreferences — Partial preferences update (JSON). " \
               "Only the keys in --json are changed; everything else is preserved. " \
               "Workflow: inspect with 'qbit app preferences | jq keys', then update."
        a.command :"set-preferences" do |c|
          c.flag :json, desc: "Partial JSON object of preference keys/values to update (required)",
                        required: true
          c.action do |g, opts, _|
            begin
              prefs = JSON.parse(opts[:json])
            rescue JSON::ParserError => e
              abort "Error: --json is not valid JSON: #{e.message}"
            end
            body = g[:client].post("/app/setPreferences", json: JSON.generate(prefs))
            Qbit::Output.json(body)
          end
        end

        # ── logout ─────────────────────────────────────────────────────────────
        a.desc "POST /api/v2/auth/logout — Log out and clear the local session file. " \
               "The next command will trigger a fresh login."
        a.command :logout do |c|
          c.action do |g, _opts, _|
            body = g[:client].logout!
            Qbit::Output.json(body)
          end
        end

      end
    end
  end
end
