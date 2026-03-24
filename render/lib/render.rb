# frozen_string_literal: true

require "json"
require "yaml"
require "erb"

module Render
  VERSION = "0.1.0"
end

require_relative "render/template"
require_relative "render/validator"
require_relative "render/template_checker"
require_relative "render/help"
require_relative "render/commands/apply"
require_relative "render/commands/schema"
require_relative "render/commands/validate"
require_relative "render/commands/check"
require_relative "render/commands/help"
