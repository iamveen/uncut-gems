# frozen_string_literal: true

require "faraday"
require "json"

module TMDB
  VERSION = "1.0.1"
end

require_relative "tmdb/client"
require_relative "tmdb/output"
require_relative "tmdb/schema"
require_relative "tmdb/commands/search"
require_relative "tmdb/commands/movie"
require_relative "tmdb/commands/tv"
require_relative "tmdb/commands/person"
require_relative "tmdb/commands/discover"
require_relative "tmdb/commands/trending"
