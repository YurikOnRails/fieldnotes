require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "manifest returns valid JSON" do
    get "/manifest.json"
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Fieldnotes", json["name"]
    assert json["icons"].any?
  end

  test "service worker returns JavaScript" do
    get "/service-worker.js"
    assert_response :success
    assert_match %r{javascript}, response.media_type
  end

  test "llms.txt is accessible" do
    get "/llms.txt"
    assert_response :success
  end
end
