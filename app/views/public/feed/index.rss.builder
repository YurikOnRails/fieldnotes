xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "Fieldnotes"
    xml.link root_url
    xml.description "Essays, builds, and field notes"
    xml.language "en"

    @essays.each do |essay|
      xml.item do
        xml.title essay.title
        xml.link essay_url(slug: essay.slug)
        xml.description essay.excerpt.to_s
        xml.pubDate essay.published_at.to_fs(:rfc822)
        xml.guid essay_url(slug: essay.slug)
      end
    end
  end
end
