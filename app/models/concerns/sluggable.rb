module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, on: :create

    validates :slug, presence: true,
                     uniqueness: true,
                     format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens allowed" }
  end

  private

  def generate_slug
    return if slug.present? || title.blank?

    base = title.parameterize
    candidate = base
    counter = 2

    while self.class.exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end
end
