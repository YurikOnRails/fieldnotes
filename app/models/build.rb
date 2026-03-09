class Build < ApplicationRecord
  include Sluggable
  include Taggable

  has_one_attached :cover do |attachable|
    attachable.variant :thumb,  resize_to_fill:  [ 400,  300], format: :avif, saver: { quality: 75 }
    attachable.variant :medium, resize_to_limit: [ 800,  600], format: :avif, saver: { quality: 80 }
    attachable.variant :full,   resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 85 }
    attachable.variant :hero,   resize_to_fill:  [1600,  900], format: :avif, saver: { quality: 85 }
  end


  STATUSES = %w[active paused completed archived].freeze
  KINDS    = %w[business oss media community other].freeze

  validates :title,  presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :kind,   inclusion: { in: KINDS }

  scope :ordered, -> { order(position: :asc) }
  scope :active,  -> { where.not(status: "archived") }
end
