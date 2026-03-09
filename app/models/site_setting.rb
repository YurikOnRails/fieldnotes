class SiteSetting < ApplicationRecord
  POSITIONS = %w[bottom_right bottom_left top_right top_left].freeze

  has_one_attached :watermark

  validates :watermark_opacity,  numericality: { in: 10..80 }, allow_nil: true
  validates :watermark_position, inclusion: { in: POSITIONS }, allow_nil: true

  def self.current
    first_or_create!(
      watermark_enabled:  false,
      watermark_position: "bottom_right",
      watermark_opacity:  30
    )
  end
end
