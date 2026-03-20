module Plex
  module Commands
    def self.register_accounts(prog)
      prog.desc "Local server accounts, Plex Home users, and MyPlex (Plex.tv) owner info"
      prog.command :accounts do |accounts|

        # ── list ──────────────────────────────────────────────────────────────
        accounts.desc "GET /accounts — List all local server accounts (NDJSON). " \
                      "Account 0 is always the server owner; additional accounts are managed users."
        accounts.command :list do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/accounts")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── get ───────────────────────────────────────────────────────────────
        accounts.desc "GET /accounts/{id} — Fetch a single local account by numeric ID. " \
                      "Use 0 or 1 for the server owner; find other IDs from 'accounts list'."
        accounts.command :get do |c|
          c.flag :id, desc: "Account ID (integer)", required: true, type: Integer
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/accounts/#{opts[:id]}")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── myplex ────────────────────────────────────────────────────────────
        accounts.desc "GET /myplex/account — Plex.tv owner account: subscription state, " \
                      "sign-in state, public/private address, and feature entitlements."
        accounts.command :myplex do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/myplex/account")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── home ──────────────────────────────────────────────────────────────
        accounts.desc "Plex Home users (requires Plex Home to be enabled on the server)"
        accounts.command :home do |home|

          # home list
          home.desc "GET /home/users — List all Plex Home users (NDJSON). " \
                    "Includes admin flag, restricted flag, and guest flag."
          home.command :list do |c|
            c.switch :raw, desc: "Return full API envelope", negatable: false
            c.action do |g, opts, _|
              body = g[:client].get("/home/users")
              Plex::Output.emit(body, raw: opts[:raw])
            end
          end

          # home get
          home.desc "GET /home/users/{id} — Fetch a single Plex Home user by ID. " \
                    "Find user IDs from 'accounts home list'."
          home.command :get do |c|
            c.flag :id, desc: "Home user ID", required: true
            c.switch :raw, desc: "Return full API envelope", negatable: false
            c.action do |g, opts, _|
              body = g[:client].get("/home/users/#{opts[:id]}")
              Plex::Output.emit(body, raw: opts[:raw])
            end
          end

        end

      end
    end
  end
end
