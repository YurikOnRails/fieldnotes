class Export < ApplicationRecord
  has_one_attached :archive

  STATUSES = %w[pending completed failed].freeze

  validates :status, inclusion: { in: STATUSES }

  scope :pending,   -> { where(status: "pending").where("expires_at > ?", Time.current) }
  scope :completed, -> { where(status: "completed") }
end
