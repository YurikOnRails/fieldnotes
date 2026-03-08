require "zip"

class ExportJob < ApplicationJob
  queue_as :default

  def self.perform_later
    return if Export.pending.exists?

    export = Export.create!(status: "pending", expires_at: 24.hours.from_now)
    super(export.id)
  end

  def perform(export_id)
    export = Export.find(export_id)

    data = collect_data
    zip_io = build_zip(data)

    export.archive.attach(
      io:           zip_io,
      filename:     "fieldnotes-export-#{Date.today}.zip",
      content_type: "application/zip"
    )
    export.update!(status: "completed")
  rescue => e
    Export.find_by(id: export_id)&.update!(status: "failed")
    raise
  ensure
    zip_io&.close!
  end

  private

  def collect_data
    {
      essays:       Essay.all.as_json,
      builds:       Build.all.as_json,
      books:        Book.all.as_json,
      now_entries:  NowEntry.all.as_json,
      field_series: FieldSeries.all.as_json,
      field_items:  FieldItem.all.as_json,
      tags:         Tag.all.as_json
    }
  end

  def build_zip(data)
    dir = "fieldnotes-export-#{Date.today}"
    tmp = Tempfile.new([ "export", ".zip" ])

    Zip::OutputStream.open(tmp.path) do |zip|
      data.each do |name, records|
        zip.put_next_entry("#{dir}/data/#{name}.json")
        zip.write(records.to_json)
      end

      zip.put_next_entry("#{dir}/README.md")
      zip.write(readme_content)
    end

    tmp
  rescue => e
    tmp&.close!
    raise
  end

  def readme_content
    <<~MD
      # Fieldnotes Export — #{Date.today}

      JSON fields match column names exactly.
      Files exported as originals from Active Storage.
      Note: binary files (photos, covers) are not included in this export.
    MD
  end
end
