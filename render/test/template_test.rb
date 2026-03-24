# frozen_string_literal: true

require "test_helper"

class TemplateTest < Minitest::Test
  # --- Parsing ---

  def test_parse_valid_template
    t = Render::Template.new(fixture_path("simple.erb"))
    assert_equal "simple", t.name
    assert_equal "Simple test template", t.description
    assert_kind_of Hash, t.schema
  end

  def test_parse_extracts_schema
    t = Render::Template.new(fixture_path("simple.erb"))
    assert_equal "object", t.schema["type"]
    assert_includes t.schema["required"], "title"
  end

  def test_parse_nested_template
    t = Render::Template.new(fixture_path("nested.erb"))
    assert_equal "nested", t.name
    assert_equal "object", t.schema.dig("properties", "movie", "type")
  end

  def test_parse_array_template
    t = Render::Template.new(fixture_path("array.erb"))
    assert_equal "array", t.schema.dig("properties", "items", "type")
  end

  def test_raises_on_missing_file
    assert_raises(Render::TemplateNotFound) do
      Render::Template.new("/nonexistent/path/template.erb")
    end
  end

  def test_raises_on_invalid_yaml_frontmatter
    assert_raises(Render::InvalidFrontmatter) do
      Render::Template.new(fixture_path("invalid_yaml.erb"))
    end
  end

  def test_raises_on_missing_frontmatter_delimiter
    # A file with no --- delimiters has no frontmatter
    Dir.mktmpdir do |dir|
      path = File.join(dir, "no_front.erb")
      File.write(path, "just a plain file\n<%= title %>")
      assert_raises(Render::InvalidFrontmatter) do
        Render::Template.new(path)
      end
    end
  end

  # --- Rendering ---

  def test_render_simple_template
    t = Render::Template.new(fixture_path("simple.erb"))
    output = t.render("title" => "Hello World")
    assert_match "Title: Hello World", output
  end

  def test_render_nested_data
    t = Render::Template.new(fixture_path("nested.erb"))
    output = t.render("movie" => { "title" => "The Matrix", "year" => 1999 })
    assert_match "The Matrix (1999)", output
  end

  def test_render_array_data
    t = Render::Template.new(fixture_path("array.erb"))
    output = t.render("items" => [{ "name" => "Alice" }, { "name" => "Bob" }])
    assert_match "- Alice", output
    assert_match "- Bob", output
  end

  def test_render_raises_on_error
    t = Render::Template.new(fixture_path("simple.erb"))
    # title is missing - ERB will raise NameError
    assert_raises(Render::RenderError) do
      t.render({})
    end
  end
end
