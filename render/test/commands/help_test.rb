# frozen_string_literal: true

require "test_helper"
require "open3"

class HelpCommandTest < Minitest::Test
  BIN = File.expand_path("../../bin/render", __dir__)

  def output
    @output ||= begin
      stdout, _stderr, _status = Open3.capture3(BIN, "help")
      stdout
    end
  end

  def test_exits_0
    _stdout, _stderr, status = Open3.capture3(BIN, "help")
    assert_equal 0, status.exitstatus
  end

  # --- Sections present ---

  def test_contains_overview_section
    assert_match(/OVERVIEW/i, output)
  end

  def test_contains_template_format_section
    assert_match(/TEMPLATE FORMAT/i, output)
  end

  def test_contains_commands_section
    assert_match(/COMMANDS/i, output)
  end

  def test_contains_exit_codes_section
    assert_match(/EXIT CODES/i, output)
  end

  def test_contains_examples_section
    assert_match(/EXAMPLES/i, output)
  end

  # --- All commands documented ---

  def test_documents_apply_command
    assert_match(/apply/, output)
  end

  def test_documents_schema_command
    assert_match(/schema/, output)
  end

  def test_documents_validate_command
    assert_match(/validate/, output)
  end

  def test_documents_check_command
    assert_match(/check/, output)
  end

  # --- Template format coverage ---

  def test_explains_frontmatter
    assert_match(/frontmatter/i, output)
  end

  def test_shows_frontmatter_fields
    assert_match(/name/, output)
    assert_match(/description/, output)
    assert_match(/schema/, output)
  end

  def test_explains_erb_context
    assert_match(/ERB/i, output)
  end

  def test_shows_nested_data_access
    assert_match(/nested/i, output)
  end

  def test_shows_array_data_access
    assert_match(/array/i, output)
  end

  # --- Exit codes documented ---

  def test_documents_apply_exit_codes
    # All four apply exit codes present
    assert_match(/template not found/i, output)
    assert_match(/invalid json/i, output)
    assert_match(/validation/i, output)
    assert_match(/render error/i, output)
  end

  # --- Examples ---

  def test_shows_pipe_example
    assert_match(/\|/, output)
  end

  def test_shows_template_path_in_examples
    assert_match(/\.erb/, output)
  end

  # --- Version ---

  def test_includes_version
    assert_match(Render::VERSION, output)
  end
end
