# frozen_string_literal: true

module Render
  module Commands
    def self.register_check(prog)
      prog.desc "Validate a template file for errors"
      prog.arg :template
      prog.command :check do |c|
        c.action do |_global, _opts, args|
          template_path = args.first

          result = Render::TemplateChecker.check(template_path)

          if result[:valid]
            puts "Template OK"
            Process.exit(0)
          else
            if result[:error]
              # File not found or top-level error
              $stderr.puts "Error: #{result[:error]}"
            else
              result[:checks].each do |step, check|
                next if check[:ok]

                label = step.to_s.tr("_", " ").capitalize
                if check[:missing]&.any?
                  $stderr.puts "#{label}: missing required fields: #{check[:missing].join(", ")}"
                elsif check[:error]
                  $stderr.puts "#{label}: #{check[:error]}"
                end
              end
            end
            Process.exit(1)
          end
        end
      end
    end
  end
end
