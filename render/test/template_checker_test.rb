# frozen_string_literal: true

require "test_helper"

class TemplateCheckerTest < Minitest::Test
  def test_valid_template_passes_all_checks
    result = Render::TemplateChecker.check(fixture_path("simple.erb"))
    assert result[:valid]
    assert_empty result[:errors]
  end

  def test_returns_check_results_for_each_step
    result = Render::TemplateChecker.check(fixture_path("simple.erb"))
    assert_includes result, :checks
    assert_includes result[:checks], :frontmatter
    assert_includes result[:checks], :schema
    assert_includes result[:checks], :erb
    assert_includes result[:checks], :required_fields
  end

  def test_invalid_yaml_detected
    result = Render::TemplateChecker.check(fixture_path("invalid_yaml.erb"))
    refute result[:valid]
    refute result[:checks][:frontmatter][:ok]
    assert_kind_of String, result[:checks][:frontmatter][:error]
  end

  def test_invalid_erb_detected
    result = Render::TemplateChecker.check(fixture_path("invalid_erb.erb"))
    refute result[:valid]
    refute result[:checks][:erb][:ok]
    assert_kind_of String, result[:checks][:erb][:error]
  end

  def test_invalid_schema_detected
    result = Render::TemplateChecker.check(fixture_path("invalid_schema.erb"))
    refute result[:valid]
    refute result[:checks][:schema][:ok]
    assert_kind_of String, result[:checks][:schema][:error]
  end

  def test_missing_required_fields_detected
    result = Render::TemplateChecker.check(fixture_path("missing_fields.erb"))
    refute result[:valid]
    refute result[:checks][:required_fields][:ok]
    assert_kind_of Array, result[:checks][:required_fields][:missing]
    assert_includes result[:checks][:required_fields][:missing], "description"
    assert_includes result[:checks][:required_fields][:missing], "schema"
  end

  def test_file_not_found
    result = Render::TemplateChecker.check("/nonexistent/template.erb")
    refute result[:valid]
    assert_kind_of String, result[:error]
  end

  def test_valid_nested_template_passes
    result = Render::TemplateChecker.check(fixture_path("nested.erb"))
    assert result[:valid]
  end

  def test_valid_array_template_passes
    result = Render::TemplateChecker.check(fixture_path("array.erb"))
    assert result[:valid]
  end
end
