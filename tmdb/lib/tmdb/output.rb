require "json"

module TMDB
  module Output
    # Unwrap common TMDB API envelopes.
    # Most list endpoints return {"results": [...], "page": 1, ...}
    # Returns [data, envelope] where data is the unwrapped content.
    def self.unwrap(body)
      return [body, body] unless body.is_a?(Hash)

      # If there's a "results" key with an array, unwrap it
      if body.key?("results") && body["results"].is_a?(Array)
        [body["results"], body]
      else
        # Single object response (e.g., /movie/{id})
        [body, body]
      end
    end

    # Print a single JSON object to stdout.
    def self.json(data)
      puts JSON.generate(data)
    end

    # Print a pretty JSON object to stdout.
    def self.pretty(data)
      puts JSON.pretty_generate(data)
    end

    # Print an array as NDJSON (one object per line).
    # If data is not an array, falls back to a single JSON line.
    def self.ndjson(data)
      if data.is_a?(Array)
        data.each { |item| puts JSON.generate(item) }
      else
        puts JSON.generate(data)
      end
    end

    # Decide output based on raw flag and whether the payload is a list.
    # raw: true  → pretty-print the full envelope
    # raw: false → unwrap, then NDJSON if array, JSON if object
    def self.emit(body, raw: false)
      if raw
        pretty(body)
      else
        data, _envelope = unwrap(body)
        if data.is_a?(Array)
          ndjson(data)
        else
          pretty(data)
        end
      end
    end
  end
end
