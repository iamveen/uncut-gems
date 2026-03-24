# frozen_string_literal: true

require "test_helper"
require "open3"

class CheckCommandTest < Minitest::Test
  BIN = File.expand_path("../../bin/render", __dir__)

  def run_check(template)
    Open3.capture3(BIN, "check", template)
  end

  def test_exits_0_for_valid_template
    _stdout, _stderr, status = run_check(fixture_path("simple.erb"))
    assert_equal 0, status.exitstatus
  end

  def test_prints_ok_for_valid_template
    stdout, _stderr, _status = run_check(fixture_path("simple.erb"))
    assert_match "ok", stdout.downcase
  end

  def test_exits_1_for_invalid_yaml
    _stdout, _stderr, status = run_check(fixture_path("invalid_yaml.erb"))
    assert_equal 1, status.exitstatus
  end

  def test_exits_1_for_invalid_erb
    _stdout, _stderr, status = run_check(fixture_path("invalid_erb.erb"))
    assert_equal 1, status.exitstatus
  end

  def test_exits_1_for_invalid_schema
    _stdout, _stderr, status = run_check(fixture_path("invalid_schema.erb"))
    assert_equal 1, status.exitstatus
  end

  def test_exits_1_for_missing_fields
    _stdout, _stderr, status = run_check(fixture_path("missing_fields.erb"))
    assert_equal 1, status.exitstatus
  end

  def test_prints_errors_to_stderr_on_failure
    _stdout, stderr, _status = run_check(fixture_path("invalid_yaml.erb"))
    assert_operator stderr.length, :>, 0
  end

  def test_exits_1_for_template_not_found
    _stdout, _stderr, status = run_check("/nonexistent/template.erb")
    assert_equal 1, status.exitstatus
  end

  def test_valid_nested_template_passes
    _stdout, _stderr, status = run_check(fixture_path("nested.erb"))
    assert_equal 0, status.exitstatus
  end

  def test_valid_array_template_passes
    _stdout, _stderr, status = run_check(fixture_path("array.erb"))
    assert_equal 0, status.exitstatus
  end
end
