class Public::NowController < Public::BaseController
  def show
    @current  = NowEntry.latest
    @previous = NowEntry.previous
    fresh_when @current
    render Views::Public::Now::ShowView.new(current: @current, previous: @previous)
  end
end
