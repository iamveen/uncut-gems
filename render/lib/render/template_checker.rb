# frozen_string_literal: true

require "yaml"
require "erb"
require "json_schemer"

module Render
  class TemplateChecker
    REQUIRED_FIELDS = %w[name description schema].freeze

    def self.check(path)
      unless File.exist?(path)
        return { valid: false, error: "Template not found: #{path}" }
      end

      raw = File.read(path)

      checks = {}
      checks[:frontmatter]    = check_frontmatter(raw, path)
      frontmatter             = checks[:frontmatter][:frontmatter]

      # Only proceed with deeper checks if frontmatter parsed successfully
      if checks[:frontmatter][:ok] && frontmatter
        checks[:required_fields] = check_required_fields(frontmatter)
        checks[:schema]          = check_schema(frontmatter["schema"])
      else
        checks[:required_fields] = { ok: false, missing: REQUIRED_FIELDS }
        checks[:schema]          = { ok: false, error: "Skipped (frontmatter invalid)" }
      end

      body              = checks[:frontmatter][:body]
      checks[:erb]      = check_erb(body || "")

      overall_valid = checks.values.all? { |c| c[:ok] }

      all_errors = checks.flat_map do |_step, c|
        next [] if c[:ok]

        [c[:error], *c[:missing]].compact
      end

      { valid: overall_valid, errors: all_errors, checks: checks.except(:frontmatter).merge(
        frontmatter: checks[:frontmatter].except(:frontmatter, :body)
      ) }
    end

    def self.check_frontmatter(raw, path)
      match = raw.match(/\A---\n(.*?)\n---\n(.*)\z/m)
      unless match
        return { ok: false, error: "Missing or malformed frontmatter delimiters" }
      end

      begin
        frontmatter = YAML.safe_load(match[1])
      rescue Psych::Exception => e
        return { ok: false, error: "Invalid YAML: #{e.message}" }
      end

      unless frontmatter.is_a?(Hash)
        return { ok: false, error: "Frontmatter is empty or not a mapping" }
      end

      { ok: true, frontmatter: frontmatter, body: match[2] }
    end

    def self.check_required_fields(frontmatter)
      missing = REQUIRED_FIELDS.reject { |f| frontmatter.key?(f) }
      if missing.empty?
        { ok: true, missing: [] }
      else
        { ok: false, missing: missing }
      end
    end

    def self.check_schema(schema)
      return { ok: false, error: "No schema defined" } if schema.nil?

      errors = JSONSchemer.validate_schema(schema).to_a

      if errors.empty?
        { ok: true }
      else
        messages = errors.map { |e| e["error"] || e["type"] }.join("; ")
        { ok: false, error: "Invalid JSON Schema: #{messages}" }
      end
    rescue => e
      { ok: false, error: "Schema validation error: #{e.message}" }
    end

    def self.check_erb(body)
      ruby_src = ERB.new(body, trim_mode: "-").src
      RubyVM::InstructionSequence.compile(ruby_src)
      { ok: true }
    rescue SyntaxError => e
      { ok: false, error: "ERB syntax error: #{e.message.gsub(/\(erb\):/, "line ")}" }
    rescue => e
      { ok: false, error: "ERB parse error: #{e.message}" }
    end

    private_class_method :check_frontmatter, :check_required_fields,
                         :check_schema, :check_erb
  end
end
