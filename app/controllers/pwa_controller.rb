class PwaController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :allow_browser, raise: false

  def manifest
    render layout: false
  end
end
