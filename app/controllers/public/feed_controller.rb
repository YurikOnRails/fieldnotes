class Public::FeedController < Public::BaseController
  def index
    @essays = Essay.published.limit(20)
    fresh_when @essays

    respond_to do |format|
      format.html
      format.rss
    end
  end
end
