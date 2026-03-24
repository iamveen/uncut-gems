# frozen_string_literal: true

require_relative "lib/render"

Gem::Specification.new do |spec|
  spec.name          = "render"
  spec.version       = Render::VERSION
  spec.authors       = ["iamveen"]
  spec.summary       = "CLI template engine for transforming JSON into formatted output"
  spec.description   = "Apply ERB templates to JSON input from stdin. Supports schema validation and template checking."
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["lib/**/*.rb", "bin/*"]
  spec.bindir        = "bin"
  spec.executables   = ["render"]

  spec.add_dependency "gli", "~> 2.21"
  spec.add_dependency "json_schemer", "~> 2.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
