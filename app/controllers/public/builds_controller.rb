class Public::BuildsController < Public::BaseController
  rate_limit to: 60, within: 1.minute

  def index
    @builds = Build.active.ordered
    @profile = Profile.instance
    fresh_when @builds
  end
end
