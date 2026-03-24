# frozen_string_literal: true

require "test_helper"

class ValidatorTest < Minitest::Test
  def schema
    {
      "type" => "object",
      "properties" => {
        "title" => { "type" => "string" },
        "year"  => { "type" => "integer" }
      },
      "required" => ["title"]
    }
  end

  def nested_schema
    {
      "type" => "object",
      "properties" => {
        "movie" => {
          "type" => "object",
          "properties" => {
            "title" => { "type" => "string" },
            "year"  => { "type" => "integer" }
          },
          "required" => ["title"]
        }
      },
      "required" => ["movie"]
    }
  end

  def array_schema
    {
      "type" => "object",
      "properties" => {
        "items" => {
          "type" => "array",
          "items" => {
            "type" => "object",
            "properties" => {
              "name" => { "type" => "string" }
            },
            "required" => ["name"]
          }
        }
      },
      "required" => ["items"]
    }
  end

  # --- Valid inputs ---

  def test_valid_input_passes
    result = Render::Validator.validate({ "title" => "Hello" }, schema)
    assert result[:valid]
    assert_empty result[:errors]
  end

  def test_valid_input_with_optional_field
    result = Render::Validator.validate({ "title" => "Hello", "year" => 2024 }, schema)
    assert result[:valid]
  end

  # --- Missing required fields ---

  def test_missing_required_field_fails
    result = Render::Validator.validate({}, schema)
    refute result[:valid]
    assert_operator result[:errors].length, :>=, 1
  end

  def test_error_mentions_missing_field
    result = Render::Validator.validate({}, schema)
    assert result[:errors].any? { |e| e.include?("title") }
  end

  # --- Wrong types ---

  def test_wrong_type_fails
    result = Render::Validator.validate({ "title" => 123 }, schema)
    refute result[:valid]
  end

  def test_wrong_type_error_mentions_field
    result = Render::Validator.validate({ "title" => 123 }, schema)
    assert result[:errors].any? { |e| e.include?("title") }
  end

  # --- Nested objects ---

  def test_valid_nested_object_passes
    result = Render::Validator.validate(
      { "movie" => { "title" => "The Matrix", "year" => 1999 } },
      nested_schema
    )
    assert result[:valid]
  end

  def test_missing_nested_required_field_fails
    result = Render::Validator.validate(
      { "movie" => { "year" => 1999 } },
      nested_schema
    )
    refute result[:valid]
  end

  def test_missing_top_level_nested_object_fails
    result = Render::Validator.validate({}, nested_schema)
    refute result[:valid]
  end

  # --- Arrays of objects ---

  def test_valid_array_passes
    result = Render::Validator.validate(
      { "items" => [{ "name" => "Alice" }, { "name" => "Bob" }] },
      array_schema
    )
    assert result[:valid]
  end

  def test_invalid_array_item_fails
    result = Render::Validator.validate(
      { "items" => [{ "name" => "Alice" }, { "bad" => "field" }] },
      array_schema
    )
    refute result[:valid]
  end

  def test_empty_array_passes
    result = Render::Validator.validate({ "items" => [] }, array_schema)
    assert result[:valid]
  end
end
