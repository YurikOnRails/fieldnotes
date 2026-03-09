class Profile < ApplicationRecord
  has_rich_text :bio
  has_one_attached :avatar

  validates :name, presence: true

  def self.instance
    first_or_create!(name: "Your Name")
  end
end
