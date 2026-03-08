class Build < ApplicationRecord
  include Sluggable
  include Taggable

  has_one_attached :cover

  STATUSES = %w[active paused completed archived].freeze
  KINDS    = %w[business oss media community other].freeze

  validates :title,  presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :kind,   inclusion: { in: KINDS }

  scope :ordered, -> { order(position: :asc) }
  scope :active,  -> { where.not(status: "archived") }
end
