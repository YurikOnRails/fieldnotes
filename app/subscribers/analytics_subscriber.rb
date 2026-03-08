class AnalyticsSubscriber
  def emit(event)
    PageView.create!(
      event:   event[:name],
      payload: event.except(:name)
    )
  rescue => e
    Rails.logger.error("AnalyticsSubscriber error: #{e.message}")
  end
end
