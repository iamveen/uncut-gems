require "json"

module Hdbits
  module Output
    # Print a single compact JSON object to stdout.
    def self.json(data)
      puts JSON.generate(data)
    end

    # Print a pretty-printed JSON value to stdout.
    def self.pretty(data)
      puts JSON.pretty_generate(data)
    end

    # Print an array as NDJSON (one compact JSON object per line).
    # Falls back to a single pretty JSON if data is not an array.
    def self.ndjson(data)
      if data.is_a?(Array)
        data.each { |item| puts JSON.generate(item) }
      else
        pretty(data)
      end
    end

    # Standard emit for list commands:
    #   raw: true  → pretty-print the full API envelope (status + data)
    #   otherwise  → unwrap data field, NDJSON if array, pretty JSON if object
    def self.emit(body, raw: false)
      if raw
        pretty(body)
      else
        data = body["data"]
        if data.is_a?(Array)
          ndjson(data)
        else
          pretty(data)
        end
      end
    end
  end
end
