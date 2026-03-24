# frozen_string_literal: true

require "json_schemer"

module Render
  class Validator
    def self.validate(data, schema)
      schemer = JSONSchemer.schema(schema)
      errors  = schemer.validate(data).to_a

      if errors.empty?
        { valid: true, errors: [] }
      else
        { valid: false, errors: format_errors(errors) }
      end
    end

    def self.format_errors(raw_errors)
      raw_errors.map do |e|
        pointer = e["data_pointer"].to_s.delete_prefix("/")
        type    = e["type"]

        case type
        when "required"
          missing = e.dig("details", "missing_keys")&.join(", ") || "unknown"
          prefix  = pointer.empty? ? "" : "#{pointer}: "
          "#{prefix}missing required field(s): #{missing}"
        when "null_type", "integer", "string", "number", "boolean", "array", "object"
          "#{pointer}: expected #{type}"
        else
          field = pointer.empty? ? "(root)" : pointer
          "#{field}: #{e["error"] || type}"
        end
      end
    end
  end
end
