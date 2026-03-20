module Plex
  module Commands
    def self.register_server(prog)
      prog.desc "Server info, preferences, activities, butler tasks, and updater"
      prog.command :server do |server|

        # ── info ──────────────────────────────────────────────────────────────
        server.desc "GET / — Server identity: name, version, platform, machineIdentifier, feature flags"
        server.command :info do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── prefs ─────────────────────────────────────────────────────────────
        server.desc "GET/PUT /:/prefs — Read or write server-level preferences"
        server.command :prefs do |c|
          c.desc "get  — list all preference keys with current values (default)\nset  — update preferences supplied as KEY=VALUE pairs"
          c.arg :action, :optional  # get | set
          c.flag [:set, :s], desc: "KEY=VALUE pairs to update (repeatable, only for set)",
                             multiple: true
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, args|
            action = args.first || "get"
            case action
            when "get"
              body = g[:client].get("/:/prefs")
              Plex::Output.emit(body, raw: opts[:raw])
            when "set"
              pairs = opts[:set]
              if pairs.empty?
                $stderr.puts "Error: provide at least one KEY=VALUE pair with --set"
                exit 1
              end
              params = pairs.each_with_object({}) do |pair, h|
                k, v = pair.split("=", 2)
                h[k] = v
              end
              body = g[:client].put("/:/prefs", params)
              Plex::Output.emit(body, raw: opts[:raw])
            else
              $stderr.puts "Error: unknown action '#{action}'. Use get or set."
              exit 1
            end
          end
        end

        # ── activities ────────────────────────────────────────────────────────
        server.desc "GET /activities — List background activities (scans, metadata refreshes, analyses)"
        server.command :activities do |c|
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, _|
            body = g[:client].get("/activities")
            Plex::Output.emit(body, raw: opts[:raw])
          end
        end

        # ── butler ────────────────────────────────────────────────────────────
        server.desc "Manage PMS scheduled maintenance butler tasks"
        server.command :butler do |c|
          c.desc "list           — show all tasks with enabled state and schedule\n" \
                 "run-all        — trigger all enabled tasks immediately\n" \
                 "cancel-all     — cancel all running tasks\n" \
                 "run <name>     — run a single task by name\n" \
                 "cancel <name>  — cancel a single task by name\n\n" \
                 "Known task names: BackupDatabase, BuildEmbeddingIndex, CleanOldBundles,\n" \
                 "CleanOldCacheFiles, DeepMediaAnalysis, DetectIntroContent, GenerateAutoTags,\n" \
                 "GenerateChapterImageFiles, RefreshLibraries, RefreshLocalMedia, SyncMyPlexWatch"
          c.arg :action          # list | run-all | cancel-all | run | cancel
          c.arg :task_name, :optional
          c.switch :raw, desc: "Return full API envelope", negatable: false
          c.action do |g, opts, args|
            action    = args[0] || "list"
            task_name = args[1]
            case action
            when "list"
              body = g[:client].get("/butler")
              Plex::Output.emit(body, raw: opts[:raw])
            when "run-all"
              body = g[:client].post("/butler")
              Plex::Output.emit(body, raw: opts[:raw])
            when "cancel-all"
              body = g[:client].delete("/butler")
              Plex::Output.emit(body, raw: opts[:raw])
            when "run", "cancel"
              unless task_name
                $stderr.puts "Error: task name required for '#{action}'"
                exit 1
              end
              body = action == "run" \
                ? g[:client].post("/butler/#{task_name}") \
                : g[:client].delete("/butler/#{task_name}")
              Plex::Output.emit(body, raw: opts[:raw])
            else
              $stderr.puts "Error: unknown action '#{action}'"
              exit 1
            end
          end
        end

        # ── updater ───────────────────────────────────────────────────────────
        server.desc "Manage PMS auto-updates"
        server.command :updater do |c|
          c.desc "status  — current version and available update\n" \
                 "check   — trigger an immediate check for a new release\n" \
                 "apply   — install a downloaded update (--tonight to defer)"
          c.arg :action, :optional
          c.switch :tonight, desc: "Defer update install to tonight's maintenance window", negatable: false
          c.switch :raw,     desc: "Return full API envelope", negatable: false
          c.action do |g, opts, args|
            action = args.first || "status"
            case action
            when "status"
              Plex::Output.emit(g[:client].get("/updater/status"), raw: opts[:raw])
            when "check"
              Plex::Output.emit(g[:client].put("/updater/check"), raw: opts[:raw])
            when "apply"
              params = opts[:tonight] ? { tonight: 1 } : {}
              Plex::Output.emit(g[:client].put("/updater/apply", params), raw: opts[:raw])
            else
              $stderr.puts "Error: unknown action '#{action}'"
              exit 1
            end
          end
        end

      end
    end
  end
end
