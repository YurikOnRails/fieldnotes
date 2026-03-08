module Sluggable
  extend ActiveSupport::Concern

  included do
    validates :slug, presence: true,
                     uniqueness: true,
                     format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens allowed" }
  end
end
