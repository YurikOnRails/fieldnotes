class FieldItem < ApplicationRecord
  KINDS = %w[photo video].freeze

  belongs_to :field_series, touch: true
  has_one_attached :photo


  validates :kind,     inclusion: { in: KINDS }
  validates :position, presence: true
  validates :youtube_url, presence: true, if: -> { kind == "video" }

  scope :ordered, -> { order(position: :asc) }
end
