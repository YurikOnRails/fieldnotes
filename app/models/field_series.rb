class FieldSeries < ApplicationRecord
  include Sluggable
  include Taggable

  KINDS = %w[photo video mixed].freeze

  has_many :field_items, dependent: :destroy

  validates :title, presence: true
  validates :kind,  inclusion: { in: KINDS }
end
