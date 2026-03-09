class Book < ApplicationRecord
  STATUSES = %w[reading completed abandoned].freeze

  has_rich_text :review

  before_validation :fetch_metadata_from_isbn, on: :create

  validates :title,  presence: true
  validates :author, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  scope :completed, -> { where(status: "completed") }
  scope :reading,   -> { where(status: "reading") }
  scope :by_year,   -> { order(year_read: :desc) }

  def cover_image_url
    return cover_url if cover_url.present?

    "https://covers.openlibrary.org/b/isbn/#{isbn}-L.jpg" if isbn.present?
  end

  private

  def fetch_metadata_from_isbn
    return if isbn.blank?

    data = OpenLibraryService.fetch(isbn: isbn.strip)
    return unless data

    self.title     = data[:title]     if title.blank?
    self.author    = data[:author]    if author.blank?
    self.cover_url = data[:cover_url] if cover_url.blank?
  end
end
