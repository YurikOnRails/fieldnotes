module ApplicationHelper
  def meta_tags(title:, description:, image: nil, type: :website, published_at: nil)
    render "shared/meta_tags",
      title: title,
      description: description,
      image: image,
      type: type,
      published_at: published_at
  end

  # AVIF-only responsive picture tag.
  # Uses :medium (800w) and :full (1920w) named variants.
  def picture_tag(attachment, alt:, sizes: "(max-width: 768px) 100vw, 90vw", loading: "lazy")
    return "" unless attachment.attached?

    srcset = [
      "#{url_for(attachment.variant(:medium))} 800w",
      "#{url_for(attachment.variant(:full))} 1920w"
    ].join(", ")

    tag.picture do
      concat tag.source(type: "image/avif", srcset: srcset, sizes: sizes)
      concat image_tag(attachment.variant(:full), alt: alt, loading: loading)
    end
  end

  # Returns watermarked photo if available, otherwise original photo.
  def field_item_photo(item)
    item.watermarked_photo.attached? ? item.watermarked_photo : item.photo
  end
end
