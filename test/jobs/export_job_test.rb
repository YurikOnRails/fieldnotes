require "test_helper"
require "zip"

class ExportJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "creates Export record with attached archive" do
    assert_difference("Export.count", 1) do
      ExportJob.perform_now(Export.create!(status: "pending", expires_at: 24.hours.from_now).id)
    end

    assert Export.last.archive.attached?
    assert_equal "completed", Export.last.status
  end

  test "export expires after 24 hours" do
    export = Export.create!(status: "pending", expires_at: 24.hours.from_now)
    ExportJob.perform_now(export.id)
    assert_in_delta 24.hours.from_now, export.reload.expires_at, 1.minute
  end

  test "archive contains expected files with valid JSON" do
    export = Export.create!(status: "pending", expires_at: 24.hours.from_now)
    ExportJob.perform_now(export.id)

    dir = "fieldnotes-export-#{Date.today}"
    tmp = Tempfile.new([ "export_test", ".zip" ])
    tmp.binmode
    tmp.write(export.archive.download)
    tmp.flush

    Zip::File.open(tmp.path) do |zip|
      %w[essays builds books now_entries field_series tags].each do |name|
        entry = zip.find_entry("#{dir}/data/#{name}.json")
        assert entry, "Missing #{name}.json"
        assert_nothing_raised { JSON.parse(entry.get_input_stream.read) }
      end

      assert zip.find_entry("#{dir}/README.md")
    end
  ensure
    tmp&.close!
  end

  test "perform_later creates pending Export and enqueues job" do
    assert_difference("Export.count", 1) do
      assert_enqueued_with(job: ExportJob) do
        ExportJob.perform_later
      end
    end

    assert Export.pending.exists?
  end

  test "perform_later does not enqueue if export already pending" do
    Export.create!(status: "pending", expires_at: 24.hours.from_now)

    assert_no_difference("Export.count") do
      assert_no_enqueued_jobs(only: ExportJob) do
        ExportJob.perform_later
      end
    end
  end

  test "marks export as failed on error" do
    export = Export.create!(status: "pending", expires_at: 24.hours.from_now)

    job = ExportJob.new
    job.define_singleton_method(:collect_data) { raise "boom" }

    assert_raises(RuntimeError) { job.perform(export.id) }
    assert_equal "failed", export.reload.status
  end
end
