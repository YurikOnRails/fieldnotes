class Admin::EssaysController < Admin::BaseController
  def index
    @essays = Essay.all
  end
end
