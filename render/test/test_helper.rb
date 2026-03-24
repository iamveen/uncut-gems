# frozen_string_literal: true

require "minitest/autorun"
require "minitest/pride"
require "render"

FIXTURES_PATH = File.expand_path("fixtures", __dir__)

def fixture_path(name)
  File.join(FIXTURES_PATH, name)
end
