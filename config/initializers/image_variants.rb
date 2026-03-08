ActiveSupport.on_load(:active_storage_attachment) do
  after_create_commit do
    case record
    when Essay, Build
      ImageVariantJob.perform_later(blob)
    when FieldItem
      ImageVariantJob.perform_later(blob, watermark: true)
    end
  end
end
