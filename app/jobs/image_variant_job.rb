class ImageVariantJob < ApplicationJob
  queue_as :default

  VARIANTS = {
    thumb:  { resize_to_fill:  [ 400,  300], format: :avif, saver: { quality: 75 } },
    medium: { resize_to_limit: [ 800,  600], format: :avif, saver: { quality: 80 } },
    full:   { resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 85 } },
    hero:   { resize_to_fill:  [1600,  900], format: :avif, saver: { quality: 85 } }
  }.freeze

  def perform(blob, watermark: false)
    return if blob.nil?
    return unless blob.is_a?(ActiveStorage::Blob) && blob.image?

    if watermark
      process_variants(blob, watermark: true)
    else
      process_variants(blob)
    end
  end

  private

  def process_variants(blob, watermark: false)
    VARIANTS.each_value do |transform|
      blob.variant(transform).processed
    end
  rescue => e
    Rails.logger.error("ImageVariantJob failed for blob #{blob.id}: #{e.message}")
  end
end
