class FieldItem < ApplicationRecord
  KINDS = %w[photo video].freeze

  belongs_to :field_series, touch: true
  has_one_attached :photo do |attachable|
    attachable.variant :thumb,  resize_to_fill:  [ 400,  300], format: :avif, saver: { quality: 75 }
    attachable.variant :medium, resize_to_limit: [ 800,  600], format: :avif, saver: { quality: 80 }
    attachable.variant :full,   resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 90 }
    attachable.variant :hero,   resize_to_fill:  [1600,  900], format: :avif, saver: { quality: 85 }
  end

  has_one_attached :watermarked_photo do |attachable|
    attachable.variant :medium, resize_to_limit: [ 800,  600], format: :avif, saver: { quality: 80 }
    attachable.variant :full,   resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 90 }
  end


  validates :kind,     inclusion: { in: KINDS }
  validates :position, presence: true
  validates :youtube_url, presence: true, if: -> { kind == "video" }

  scope :ordered, -> { order(position: :asc) }
end
