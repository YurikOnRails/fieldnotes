class Public::FeedController < Public::BaseController
  def index
    @essays = Essay.published.includes(:cover_attachment).limit(20)
    fresh_when @essays

    respond_to do |format|
      format.html { render Views::Public::Feed::IndexView.new(essays: @essays) }
      format.rss
    end
  end
end
