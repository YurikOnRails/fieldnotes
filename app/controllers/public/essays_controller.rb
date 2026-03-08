class Public::EssaysController < Public::BaseController
  rate_limit to: 60, within: 1.minute, only: :index

  def index
    @essays = Essay.published
    fresh_when @essays
  end

  def show
    @essay = Essay.published.find_by(slug: params[:slug])
    return head :not_found unless @essay

    Rails.event.notify("essay.viewed", essay_id: @essay.id, path: request.path)
    fresh_when @essay

    respond_to do |format|
      format.html
      format.rss
      format.md
    end
  end
end
