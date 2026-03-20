# frozen_string_literal: true

require_relative "lib/hdbits"

Gem::Specification.new do |spec|
  spec.name          = "hdbits"
  spec.version       = Hdbits::VERSION
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = "CLI wrapper around the HDBits private tracker JSON API"
  spec.description   = "A command-line tool for interacting with the HDBits private tracker API. " \
                       "Outputs raw JSON/NDJSON to stdout for easy piping to jq and other tools."
  spec.homepage      = "https://github.com/yourusername/hdbits"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    Dir["{bin,lib}/**/*", "LICENSE", "README.md", "CHANGELOG.md"].reject { |f| File.directory?(f) }
  end
  spec.bindir        = "bin"
  spec.executables   = ["hdbits"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "gli", "~> 2.21"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
