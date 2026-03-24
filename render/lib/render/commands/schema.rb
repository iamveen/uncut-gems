# frozen_string_literal: true

require "yaml"

module Render
  module Commands
    def self.register_schema(prog)
      prog.desc "Show the schema for a template"
      prog.arg :template
      prog.command :schema do |c|
        c.action do |_global, _opts, args|
          template_path = args.first

          begin
            template = Render::Template.new(template_path)
          rescue Render::TemplateNotFound => e
            $stderr.puts "Error: #{e.message}"
            Process.exit(1)
          end

          puts YAML.dump({
            "name"        => template.name,
            "description" => template.description,
            "schema"      => template.schema
          })
        end
      end
    end
  end
end
