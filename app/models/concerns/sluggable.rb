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
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
