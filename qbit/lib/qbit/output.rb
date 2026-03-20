# frozen_string_literal: true

require "json"

module Qbit
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
    def self.ndjson(data)
      if data.is_a?(Array)
        data.each { |item| puts JSON.generate(item) }
      else
        puts JSON.generate(data)
      end
    end

    # Standard emit: NDJSON for arrays, pretty JSON for objects.
    # raw: true returns the value as pretty-printed JSON regardless.
    def self.emit(body, raw: false)
      if raw
        pretty(body)
      elsif body.is_a?(Array)
        ndjson(body)
      else
        pretty(body)
      end
    end

    # Convert comma-separated hash input to qBit's pipe-separated API format.
    # Passes "all" through unchanged.
    def self.hashes_param(csv)
      return "all" if csv.strip.downcase == "all"
      csv.split(",").map(&:strip).join("|")
    end

    # Normalise comma-separated tags (strips whitespace, rejoins with commas).
    def self.tags_param(csv)
      csv.split(",").map(&:strip).join(",")
    end
  end
end
