# frozen_string_literal: true

module Render
  module Commands
    def self.register_help(prog)
      prog.desc "Show detailed usage information"
      prog.command :help do |c|
        c.action do |_global, _opts, _args|
          puts Render::Help.text
        end
      end
    end
  end
end
