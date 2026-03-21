module TMDB
  module Commands
    def self.register_trending(prog)
      prog.desc "Get trending movies, TV shows, and people"
      prog.command :trending do |c|
        c.flag "media-type", desc: "Media type (default: all)", default_value: "all"
        c.flag "time-window", desc: "Time window (default: week)", default_value: "week"
        c.flag :page, desc: "Page number (default: 1)", type: Integer, default_value: 1
        c.flag :language, desc: "Language code (e.g., en-US)", default_value: "en-US"
        c.switch :raw, desc: "Return full API envelope", negatable: false

        c.action do |g, opts, _|
          media_type = opts["media-type"]
          time_window = opts["time-window"]

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

          body = g[:client].get("trending/#{media_type}/#{time_window}", params)
          TMDB::Output.emit(body, raw: opts[:raw])
        end
      end
    end
  end
end
