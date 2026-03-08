class Book < ApplicationRecord
  STATUSES = %w[reading completed abandoned].freeze

  validates :title,  presence: true
  validates :author, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  scope :completed, -> { where(status: "completed") }
  scope :by_year,   -> { order(year_read: :desc) }
end
