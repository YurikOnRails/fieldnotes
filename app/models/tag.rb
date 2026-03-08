class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :essays,       through: :taggings, source: :taggable, source_type: "Essay"
  has_many :builds,       through: :taggings, source: :taggable, source_type: "Build"
  has_many :field_series, through: :taggings, source: :taggable, source_type: "FieldSeries"

  validates :name, presence: true, uniqueness: true
end
