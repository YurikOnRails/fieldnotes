class NowEntry < ApplicationRecord
  has_rich_text :body

  validates :published_at, presence: true

  scope :previous, -> { order(published_at: :desc).offset(1) }

  def self.latest = order(published_at: :desc).first
end
