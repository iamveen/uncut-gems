# frozen_string_literal: true

module Render
  module Commands
    def self.register_validate(prog)
      prog.desc "Validate JSON input against a template schema"
      prog.arg :template
      prog.command :validate do |c|
        c.action do |_global, _opts, args|
          template_path = args.first

          begin
            template = Render::Template.new(template_path)
          rescue Render::TemplateNotFound => e
            $stderr.puts "Error: #{e.message}"
            Process.exit(1)
          end

          raw = $stdin.read

          begin
            data = JSON.parse(raw)
          rescue JSON::ParserError => e
            $stderr.puts "Invalid JSON: #{e.message}"
            Process.exit(1)
          end

          result = Render::Validator.validate(data, template.schema)

          if result[:valid]
            puts "Valid"
            Process.exit(0)
          else
            result[:errors].each { |e| $stderr.puts "  - #{e}" }
            Process.exit(1)
          end
        end
      end
    end
  end
end
