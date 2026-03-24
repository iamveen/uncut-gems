# frozen_string_literal: true

require "test_helper"
require "open3"

class ApplyCommandTest < Minitest::Test
  BIN = File.expand_path("../../bin/render", __dir__)

  def run_apply(template, stdin: "{}", env: {})
    cmd = [BIN, "apply", template]
    Open3.capture3(env, *cmd, stdin_data: stdin)
  end

  # --- Success ---

  def test_renders_simple_template
    stdout, stderr, status = run_apply(
      fixture_path("simple.erb"),
      stdin: '{"title": "Hello World"}'
    )
    assert status.success?, "Expected success, got stderr: #{stderr}"
    assert_match "Title: Hello World", stdout
  end

  def test_renders_nested_template
    stdout, _stderr, status = run_apply(
      fixture_path("nested.erb"),
      stdin: '{"movie": {"title": "The Matrix", "year": 1999}}'
    )
    assert status.success?
    assert_match "The Matrix (1999)", stdout
  end

  def test_renders_array_template
    stdout, _stderr, status = run_apply(
      fixture_path("array.erb"),
      stdin: '{"items": [{"name": "Alice"}, {"name": "Bob"}]}'
    )
    assert status.success?
    assert_match "Alice", stdout
    assert_match "Bob", stdout
  end

  def test_output_goes_to_stdout
    stdout, stderr, _status = run_apply(
      fixture_path("simple.erb"),
      stdin: '{"title": "Test"}'
    )
    assert_match "Title: Test", stdout
    refute_match "Title:", stderr
  end

  # --- Exit code 1: Template not found ---

  def test_exits_1_when_template_not_found
    _stdout, stderr, status = run_apply("/nonexistent/template.erb")
    assert_equal 1, status.exitstatus
    assert_match "not found", stderr.downcase
  end

  # --- Exit code 2: Invalid JSON ---

  def test_exits_2_on_invalid_json
    _stdout, stderr, status = run_apply(
      fixture_path("simple.erb"),
      stdin: "not json at all"
    )
    assert_equal 2, status.exitstatus
    assert_match "invalid json", stderr.downcase
  end

  # --- Exit code 3: Validation failure ---

  def test_exits_3_on_schema_validation_failure
    _stdout, stderr, status = run_apply(
      fixture_path("simple.erb"),
      stdin: '{"wrong_field": "value"}'
    )
    assert_equal 3, status.exitstatus
    assert_match "title", stderr
  end

  # --- Exit code 4: Render error ---

  def test_exits_4_on_render_error
    _stdout, stderr, status = run_apply(
      fixture_path("invalid_erb.erb"),
      stdin: '{"title": "test"}'
    )
    assert_equal 4, status.exitstatus
    assert_operator stderr.length, :>, 0
  end
end
