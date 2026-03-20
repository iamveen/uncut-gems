require "json"

module Plex
  module Output
    # Unwrap the standard Plex MediaContainer envelope.
    # Returns [data, envelope] where data is the unwrapped content.
    def self.unwrap(body)
      return [body, body] unless body.is_a?(Hash)
      mc = body["MediaContainer"]
      return [body, body] unless mc.is_a?(Hash)

      # Find the first array value inside MediaContainer — that's the list.
      list_key = mc.keys.find { |k| mc[k].is_a?(Array) }
      if list_key
        [mc[list_key], body]
      else
        # No array — return the MediaContainer attributes themselves.
        [mc, body]
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
