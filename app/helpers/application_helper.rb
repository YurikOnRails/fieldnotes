module ApplicationHelper
  def meta_tags(title:, description:, image: nil, type: :website, published_at: nil)
    render "shared/meta_tags",
      title: title,
      description: description,
      image: image,
      type: type,
      published_at: published_at
  end

  def picture_tag(attachment, alt:, sizes: nil)
    return "" unless attachment.attached?

    tag.picture do
      concat tag.source srcset: url_for(attachment.variant(:full)), type: "image/avif"
      concat tag.source srcset: url_for(attachment.variant(:medium)), type: "image/webp"
      concat image_tag(attachment.variant(:thumb), alt: alt, sizes: sizes, loading: "lazy")
    end
  end
end
