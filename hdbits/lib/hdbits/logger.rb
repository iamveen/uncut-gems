module Hdbits
  class Logger
    LEVELS = %w[debug info warn error fatal].freeze

    def initialize(level: "error", output: $stderr)
      unless LEVELS.include?(level.to_s.downcase)
        raise ArgumentError, "Invalid log level '#{level}'. Must be one of: #{LEVELS.join(", ")}"
      end

      @level  = LEVELS.index(level.to_s.downcase)
      @output = output
    end

    LEVELS.each_with_index do |name, idx|
      define_method(name) do |msg|
        write(name, msg) if idx >= @level
      end
    end

    private

    def write(level, msg)
      @output.puts "[#{level.upcase}] #{msg}"
    rescue IOError
      # Output stream closed — silently swallow
    end
  end
end
