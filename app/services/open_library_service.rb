class OpenLibraryService
  BASE_URL   = "https://openlibrary.org/api/books"
  COVER_URL  = "https://covers.openlibrary.org/b/isbn/%s-L.jpg"
  CACHE_TTL  = 7.days

  def self.fetch(isbn:, http: Net::HTTP)
    Rails.cache.fetch("open_library:#{isbn}", expires_in: CACHE_TTL) do
      fetch_from_api(isbn, http)
    end
  end

  def self.fetch_from_api(isbn, http)
    uri  = URI("#{BASE_URL}?bibkeys=ISBN:#{isbn}&format=json&jscmd=data")
    resp = http.get_response(uri)

    return nil unless resp.is_a?(Net::HTTPSuccess)

    data = JSON.parse(resp.body)
    book = data["ISBN:#{isbn}"]
    return nil if book.nil? || book.empty?

    {
      title:     book["title"],
      author:    book.dig("authors", 0, "name"),
      cover_url: COVER_URL % isbn,
      year:      book["publish_date"]&.then { |d| d.scan(/\d{4}/).first&.to_i }
    }
  rescue => e
    Rails.logger.error("OpenLibraryService error: #{e.message}")
    nil
  end
  private_class_method :fetch_from_api
end
