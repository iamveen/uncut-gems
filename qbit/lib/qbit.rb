# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "json"

module Qbit
  VERSION = "1.0.0"
end

require_relative "qbit/client"
require_relative "qbit/output"
require_relative "qbit/schema"
require_relative "qbit/commands/torrent"
require_relative "qbit/commands/category"
require_relative "qbit/commands/tag"
require_relative "qbit/commands/transfer"
require_relative "qbit/commands/app"
