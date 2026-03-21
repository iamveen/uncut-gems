# frozen_string_literal: true

require_relative "lib/tmdb"

Gem::Specification.new do |spec|
  spec.name          = "tmdb"
  spec.version       = TMDB::VERSION
  spec.authors       = ["iamveen"]
  spec.email         = ["iamveen@users.noreply.github.com"]

  spec.summary       = "CLI wrapper around The Movie Database (TMDB) API"
  spec.description   = "A composable command-line tool for interacting with TMDB API. " \
                       "Outputs raw JSON/NDJSON to stdout for easy piping to jq and other tools. " \
                       "Designed for automation, scripting, and LLM agent use."
  spec.homepage      = "https://github.com/iamveen/uncut-gems"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/iamveen/uncut-gems/tree/main/tmdb"
  spec.metadata["changelog_uri"]   = "https://github.com/iamveen/uncut-gems/blob/main/tmdb/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir[
    "lib/**/*.rb",
    "bin/*",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.bindir        = "bin"
  spec.executables   = ["tmdb"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "gli", "~> 2.21"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
