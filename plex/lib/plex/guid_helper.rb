module Plex
  module GuidHelper
    # Extract ID from a Guid array by prefix (e.g. "imdb", "tmdb", "tvdb")
    # Returns the ID without the prefix and ://, or nil if not found
    #
    # @param guids [Array<Hash>] Array of Guid hashes from Plex API
    # @param prefix [String] Prefix to match (e.g. "imdb", "tmdb", "tvdb")
    # @return [String, nil] The extracted ID or nil
    def self.extract(guids, prefix)
      guids.find { |g| g["id"]&.start_with?("#{prefix}://") }
           &.dig("id")
           &.delete_prefix("#{prefix}://")
    end
  end
end
