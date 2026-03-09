class Admin::BaseController < ApplicationController
  before_action :require_authentication
  layout "admin"

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to admin_root_path, alert: "Record not found"
  end
end
