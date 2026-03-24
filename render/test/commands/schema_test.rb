# frozen_string_literal: true

require "test_helper"
require "open3"

class SchemaCommandTest < Minitest::Test
  BIN = File.expand_path("../../bin/render", __dir__)

  def run_schema(template)
    Open3.capture3(BIN, "schema", template)
  end

  def test_outputs_schema_yaml
    stdout, _stderr, status = run_schema(fixture_path("simple.erb"))
    assert status.success?
    parsed = YAML.safe_load(stdout)
    assert_equal "simple", parsed["name"]
    assert_equal "object", parsed.dig("schema", "type")
  end

  def test_output_includes_description
    stdout, _stderr, _status = run_schema(fixture_path("simple.erb"))
    parsed = YAML.safe_load(stdout)
    assert_equal "Simple test template", parsed["description"]
  end

  def test_output_includes_nested_schema
    stdout, _stderr, status = run_schema(fixture_path("nested.erb"))
    assert status.success?
    parsed = YAML.safe_load(stdout)
    assert_equal "object", parsed.dig("schema", "properties", "movie", "type")
  end

  def test_exits_1_when_template_not_found
    _stdout, stderr, status = run_schema("/nonexistent/template.erb")
    assert_equal 1, status.exitstatus
    assert_match "not found", stderr.downcase
  end
end
