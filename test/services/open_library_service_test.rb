require "test_helper"
require "net/http"

class OpenLibraryServiceTest < ActiveSupport::TestCase
  VALID_ISBN   = "9780134757599"
  UNKNOWN_ISBN = "0000000000"

  setup do
    Rails.cache.clear
  end

  test "fetch returns hash with title, author, cover_url, year" do
    result = OpenLibraryService.fetch(isbn: VALID_ISBN, http: fake_http(VALID_ISBN))

    assert_not_nil result
    assert_equal "Refactoring", result[:title]
    assert_equal "Martin Fowler", result[:author]
    assert_includes result[:cover_url], VALID_ISBN
    assert_equal 2018, result[:year]
  end

  test "returns nil on API failure" do
    result = OpenLibraryService.fetch(isbn: UNKNOWN_ISBN, http: failing_http)
    assert_nil result
  end

  test "caches results for subsequent calls" do
    call_count = 0
    counting_http = fake_http(VALID_ISBN, on_call: -> { call_count += 1 })

    with_memory_cache do
      OpenLibraryService.fetch(isbn: VALID_ISBN, http: counting_http)
      OpenLibraryService.fetch(isbn: VALID_ISBN, http: counting_http)
    end

    assert_equal 1, call_count
  end

  private

  def fake_http(isbn, on_call: nil)
    body = {
      "ISBN:#{isbn}" => {
        "title"        => "Refactoring",
        "authors"      => [{ "name" => "Martin Fowler" }],
        "publish_date" => "2018"
      }
    }.to_json

    resp = Net::HTTPSuccess.new("1.1", "200", "OK")
    resp.instance_variable_set(:@body, body)
    resp.instance_variable_set(:@read, true)

    http = Object.new
    http.define_singleton_method(:get_response) do |_uri|
      on_call&.call
      resp
    end
    http
  end

  def with_memory_cache
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = original
  end

  def failing_http
    resp = Net::HTTPNotFound.new("1.1", "404", "Not Found")
    resp.instance_variable_set(:@body, "{}")
    resp.instance_variable_set(:@read, true)

    http = Object.new
    http.define_singleton_method(:get_response) { |_uri| resp }
    http
  end
end
