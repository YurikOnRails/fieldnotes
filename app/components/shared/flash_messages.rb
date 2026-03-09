# frozen_string_literal: true

class Components::Shared::FlashMessages < Components::Base
  def initialize(flash)
    @flash = flash
  end

  def view_template
    return if @flash.empty?

    div do
      @flash.each do |type, message|
        p(class: flash_classes(type)) { plain message }
      end
    end
  end

  private

  def flash_classes(type)
    base = "px-4 py-3 rounded-lg mb-4 text-[0.9375rem]"
    type == "notice" \
      ? "#{base} bg-green-bg text-green-text"
      : "#{base} bg-red-bg text-red-text"
  end
end
