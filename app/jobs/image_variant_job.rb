class ImageVariantJob < ApplicationJob
  queue_as :default

  VARIANTS = {
    thumb:  { resize_to_fill:  [ 400,  300], format: :avif, saver: { quality: 75 } },
    medium: { resize_to_limit: [ 800,  600], format: :avif, saver: { quality: 80 } },
    full:   { resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 90 } },
    hero:   { resize_to_fill:  [1600,  900], format: :avif, saver: { quality: 85 } }
  }.freeze

  # Accepts:
  #   ImageVariantJob.perform_later(blob)                        — plain variants (essays, builds)
  #   ImageVariantJob.perform_later(field_item, watermark: true) — field item with watermark
  def perform(record, watermark: false)
    case record
    when ActiveStorage::Blob
      process_plain_variants(record)
    when FieldItem
      process_plain_variants(record.photo.blob) if record.photo.attached?
      process_watermarked(record) if watermark
    end
  end

  private

  def process_plain_variants(blob)
    return unless blob&.image?
    VARIANTS.each_value { |transform| blob.variant(transform).processed }
  rescue => e
    Rails.logger.error("ImageVariantJob plain failed for blob #{blob&.id}: #{e.message}")
  end

  def process_watermarked(field_item)
    return unless field_item.photo.attached?

    setting = SiteSetting.current

    field_item.photo.blob.open do |original_file|
      image = Vips::Image.new_from_file(original_file.path)
      image = apply_watermark(image, setting) if setting.watermark_enabled? && setting.watermark.attached?

      Tempfile.create(["wm_base", ".png"]) do |tmp|
        image.write_to_file(tmp.path)

        watermarked_blob = ActiveStorage::Blob.create_and_upload!(
          io:           File.open(tmp.path),
          filename:     "wm_#{field_item.photo.blob.filename}",
          content_type: "image/png"
        )

        field_item.watermarked_photo.attach(watermarked_blob)
      end
    end

    wm_blob = field_item.reload.watermarked_photo.blob
    return unless wm_blob

    [
      { resize_to_limit: [ 800,  600], format: :avif, saver: { quality: 80 } },
      { resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 90 } }
    ].each { |t| wm_blob.variant(t).processed }
  rescue => e
    Rails.logger.error("ImageVariantJob watermark failed for FieldItem #{field_item.id}: #{e.message}")
  end

  def apply_watermark(image, setting)
    setting.watermark.blob.open do |wm_file|
      watermark = Vips::Image.new_from_file(wm_file.path)

      scale     = (image.width * 0.12).to_f / watermark.width
      watermark = watermark.resize(scale)

      if watermark.bands == 4
        opacity   = setting.watermark_opacity / 100.0
        alpha     = (watermark[3] * opacity).cast(:uchar)
        watermark = watermark.extract_band(0, n: 3).bandjoin(alpha)
      end

      left, top = watermark_coords(image, watermark, setting.watermark_position)
      return image.composite(watermark, :over, x: left, y: top)
    end
  rescue => e
    Rails.logger.warn("apply_watermark failed: #{e.message}")
    image
  end

  def watermark_coords(image, watermark, position)
    pad = 24
    case position
    when "bottom_left"  then [pad,                                   image.height - watermark.height - pad]
    when "top_right"    then [image.width - watermark.width - pad,   pad]
    when "top_left"     then [pad,                                    pad]
    else                     [image.width - watermark.width - pad,   image.height - watermark.height - pad]
    end
  end
end
