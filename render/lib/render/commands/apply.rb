# frozen_string_literal: true

module Render
  module Commands
    def self.register_apply(prog)
      prog.desc "Render stdin JSON through a template"
      prog.arg :template
      prog.command :apply do |c|
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
            Process.exit(2)
          end

          result = Render::Validator.validate(data, template.schema)
          unless result[:valid]
            $stderr.puts "Validation failed:"
            result[:errors].each { |e| $stderr.puts "  - #{e}" }
            Process.exit(3)
          end

          begin
            puts template.render(data)
          rescue Render::RenderError => e
            $stderr.puts "Render error: #{e.message}"
            Process.exit(4)
          end
        end
      end
    end
  end
end
