Rails.application.config.after_initialize do
  Rails.event.subscribe(AnalyticsSubscriber.new)
end
