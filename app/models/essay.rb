class Essay < ApplicationRecord
  include Sluggable
  include Taggable

  has_rich_text :content
  has_one_attached :cover


  STATUSES = %w[draft published].freeze

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
end
