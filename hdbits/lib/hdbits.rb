# frozen_string_literal: true

require_relative "hdbits/logger"
require_relative "hdbits/client"
require_relative "hdbits/output"
require_relative "hdbits/schema"
require_relative "hdbits/commands/test"
require_relative "hdbits/commands/user"
require_relative "hdbits/commands/tags"
require_relative "hdbits/commands/wishlist"
require_relative "hdbits/commands/torrent"
require_relative "hdbits/commands/top"
require_relative "hdbits/commands/subtitles"
require_relative "hdbits/commands/rss"

module Hdbits
  VERSION = "1.0.0"
end
