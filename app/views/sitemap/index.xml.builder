xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do

  # Static pages
  [ root_url, essays_url, builds_url, books_url, field_index_url, now_url,
    about_url, contact_url, uses_url ].each do |url|
    xml.url { xml.loc url }
  end

  # Essays
  @essays.each do |essay|
    xml.url do
      xml.loc   essay_url(slug: essay.slug)
      xml.lastmod essay.updated_at.iso8601
      xml.changefreq "monthly"
      xml.priority "0.8"
    end
  end

  # Field series
  @series.each do |series|
    xml.url do
      xml.loc   field_url(slug: series.slug)
      xml.lastmod series.updated_at.iso8601
      xml.changefreq "yearly"
      xml.priority "0.5"
    end
  end

end
