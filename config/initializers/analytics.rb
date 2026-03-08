Rails.application.config.after_initialize do
  TRACKED_EVENTS = %w[essay.viewed field.viewed].freeze

  Rails.event.subscribe(AnalyticsSubscriber.new) do |event|
    TRACKED_EVENTS.include?(event[:name])
  end
end
