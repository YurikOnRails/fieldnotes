# frozen_string_literal: true

class Components::Shared::EmptyState < Components::Base
  def initialize(message)
    @message = message
  end

  def view_template
    p(class: "text-muted text-center py-16") { plain @message }
  end
end
