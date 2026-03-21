# frozen_string_literal: true

require "faraday"
require "json"

module Plex
  VERSION = "1.0.1"
end

require_relative "plex/client"
require_relative "plex/output"
require_relative "plex/guid_helper"
require_relative "plex/schema"
require_relative "plex/commands/server"
require_relative "plex/commands/library"
require_relative "plex/commands/metadata"
require_relative "plex/commands/search"
require_relative "plex/commands/sessions"
require_relative "plex/commands/history"
require_relative "plex/commands/movie"
require_relative "plex/commands/playlists"
require_relative "plex/commands/collections"
require_relative "plex/commands/hubs"
require_relative "plex/commands/scrobble"
require_relative "plex/commands/dvr"
require_relative "plex/commands/accounts"
