class Public::NowController < Public::BaseController
  def show
    @current = NowEntry.latest
    @previous = NowEntry.previous
    fresh_when @current
  end
end
