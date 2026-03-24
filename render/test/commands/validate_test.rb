# frozen_string_literal: true

require "test_helper"
require "open3"

class ValidateCommandTest < Minitest::Test
  BIN = File.expand_path("../../bin/render", __dir__)

  def run_validate(template, stdin: "{}")
    Open3.capture3(BIN, "validate", template, stdin_data: stdin)
  end

  def test_exits_0_on_valid_input
    _stdout, _stderr, status = run_validate(
      fixture_path("simple.erb"),
      stdin: '{"title": "Hello"}'
    )
    assert_equal 0, status.exitstatus
  end

  def test_prints_valid_on_success
    stdout, _stderr, _status = run_validate(
      fixture_path("simple.erb"),
      stdin: '{"title": "Hello"}'
    )
    assert_match "valid", stdout.downcase
  end

  def test_exits_1_on_invalid_input
    _stdout, _stderr, status = run_validate(
      fixture_path("simple.erb"),
      stdin: '{"wrong": "field"}'
    )
    assert_equal 1, status.exitstatus
  end

  def test_prints_errors_to_stderr_on_failure
    _stdout, stderr, _status = run_validate(
      fixture_path("simple.erb"),
      stdin: '{"wrong": "field"}'
    )
    assert_match "title", stderr
  end

  def test_exits_1_when_template_not_found
    _stdout, _stderr, status = run_validate("/nonexistent/template.erb")
    assert_equal 1, status.exitstatus
  end

  def test_exits_1_on_invalid_json_input
    _stdout, stderr, status = run_validate(
      fixture_path("simple.erb"),
      stdin: "not json"
    )
    assert_equal 1, status.exitstatus
    assert_match "invalid json", stderr.downcase
  end
end
