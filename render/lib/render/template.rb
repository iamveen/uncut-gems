# frozen_string_literal: true

require "yaml"
require "erb"

module Render
  class TemplateNotFound < StandardError; end
  class InvalidFrontmatter < StandardError; end
  class RenderError < StandardError; end

  class Template
    FRONTMATTER_PATTERN = /\A---\n(.*?)\n---\n(.*)\z/m

    attr_reader :name, :description, :schema

    def initialize(path)
      raise TemplateNotFound, "Template not found: #{path}" unless File.exist?(path)

      raw = File.read(path)
      @frontmatter, @body = parse(raw, path)
      @name        = @frontmatter["name"]
      @description = @frontmatter["description"]
      @schema      = @frontmatter["schema"]
    end

    def render(data)
      b = binding
      data.each { |k, v| b.local_variable_set(k.to_sym, v) }
      ERB.new(@body, trim_mode: "-").result(b)
    rescue RenderError
      raise
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise RenderError, e.message
    end

    private

    def parse(raw, path)
      match = FRONTMATTER_PATTERN.match(raw)
      raise InvalidFrontmatter, "Missing or malformed frontmatter in: #{path}" unless match

      begin
        frontmatter = YAML.safe_load(match[1])
      rescue Psych::Exception => e
        raise InvalidFrontmatter, "Invalid YAML frontmatter in #{path}: #{e.message}"
      end

      raise InvalidFrontmatter, "Frontmatter is empty in: #{path}" unless frontmatter.is_a?(Hash)

      [frontmatter, match[2]]
    end
  end
end
