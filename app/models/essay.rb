class Essay < ApplicationRecord
  include Sluggable
  include Taggable

  has_rich_text :content
  has_one_attached :cover do |attachable|
    attachable.variant :thumb,  resize_to_fill:  [ 400,  300], format: :avif, saver: { quality: 75 }
    attachable.variant :medium, resize_to_limit: [ 800,  600], format: :avif, saver: { quality: 80 }
    attachable.variant :full,   resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 85 }
    attachable.variant :hero,   resize_to_fill:  [1600,  900], format: :avif, saver: { quality: 85 }
  end


  STATUSES = %w[draft published].freeze

  before_save :set_published_at

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :published, -> { where(status: "published").order(published_at: :desc) }
  scope :drafts,    -> { where(status: "draft") }

  def published?
    status == "published"
  end

  def draft?
    status == "draft"
  end

  private

  def set_published_at
    self.published_at = Time.current if published? && published_at.blank?
  end
end
