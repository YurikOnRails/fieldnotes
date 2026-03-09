# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::PictureTag
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::URLFor
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavascriptImportmapTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::Notice
  include Phlex::Rails::Helpers::ControllerName
  include Phlex::Rails::Helpers::ControllerPath

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  private

  def cx(*classes)
    classes.flatten.compact.join(" ")
  end

  # Phlex 2.x removed `unsafe_raw`; use `raw(safe(...))` internally.
  def unsafe_raw(content)
    raw safe(content.to_s)
  end
end
