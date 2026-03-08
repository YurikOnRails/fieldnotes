require "test_helper"

class ImageVariantJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "does not raise on nil" do
    assert_nothing_raised { ImageVariantJob.perform_now(nil) }
  end

  test "does not raise on non-blob argument" do
    assert_nothing_raised { ImageVariantJob.perform_now("not-a-blob") }
  end

  test "enqueues job after essay cover is attached" do
    essay = Essay.create!(title: "Test", slug: "test-img-#{SecureRandom.hex(4)}", status: "draft")
    assert_enqueued_with(job: ImageVariantJob) do
      essay.cover.attach(
        io: File.open(test_image_path),
        filename: "cover.jpg",
        content_type: "image/jpeg"
      )
    end
  end

  test "enqueues job after field_item photo is attached" do
    item = FieldItem.create!(field_series: field_series(:iceland), kind: "photo", position: 99)
    assert_enqueued_with(job: ImageVariantJob) do
      item.photo.attach(
        io: File.open(test_image_path),
        filename: "photo.jpg",
        content_type: "image/jpeg"
      )
    end
  end

  private

  def test_image_path
    Rails.root.join("test/fixtures/files/test_image.jpg")
  end
end
