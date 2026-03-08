class SitemapController < ApplicationController
  allow_unauthenticated_access

  def index
    @essays = Essay.published
    @series = FieldSeries.order(created_at: :desc)

    expires_in 1.hour, public: true
  end
end
