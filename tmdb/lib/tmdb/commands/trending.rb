module TMDB
  module Commands
    def self.register_trending(prog)
      prog.desc "Get trending movies, TV shows, and people"
      prog.command :trending do |c|
        c.desc "Get trending items by media type and time window. Returns NDJSON."
        c.arg :media_type, desc: "Media type: all, movie, tv, person"
        c.arg :time_window, desc: "Time window: day, week"

        c.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
        c.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
        c.switch :raw, desc: "Return full API envelope", negatable: false

        c.action do |g, opts, args|
          unless args.size == 2
            $stderr.puts "Error: trending requires media_type and time_window arguments"
            $stderr.puts "Usage: tmdb trending <media_type> <time_window>"
            $stderr.puts "  media_type: all, movie, tv, person"
            $stderr.puts "  time_window: day, week"
            exit 1
          end

          media_type = args[0]
          time_window = args[1]

          unless %w[all movie tv person].include?(media_type)
            $stderr.puts "Error: Invalid media_type '#{media_type}'"
            $stderr.puts "Valid options: all, movie, tv, person"
            exit 1
          end

          unless %w[day week].include?(time_window)
            $stderr.puts "Error: Invalid time_window '#{time_window}'"
            $stderr.puts "Valid options: day, week"
            exit 1
          end

          params = {
            page: opts[:page],
            language: opts[:language]
          }

          body = g[:client].get("/trending/#{media_type}/#{time_window}", params)
          TMDB::Output.emit(body, raw: opts[:raw])
        end
      end
    end
  end
end
