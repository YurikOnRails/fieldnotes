class Admin::BuildsController < Admin::BaseController
  before_action :set_build, only: [:edit, :update, :destroy]

  def index
    @builds = Build.ordered
    render Views::Admin::Builds::IndexView.new(builds: @builds)
  end

  def new
    @build = Build.new
    render Views::Admin::Builds::NewView.new(build: @build)
  end

  def create
    @build = Build.new(build_params)
    @build.position ||= Build.maximum(:position).to_i + 1
    if @build.save
      redirect_to edit_admin_build_url(@build), notice: "Build created"
    else
      render Views::Admin::Builds::NewView.new(build: @build), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Admin::Builds::EditView.new(build: @build)
  end

  def update
    if @build.update(build_params)
      redirect_to edit_admin_build_url(@build), notice: "Build updated"
    else
      render Views::Admin::Builds::EditView.new(build: @build), status: :unprocessable_entity
    end
  end

  def destroy
    @build.destroy
    redirect_to admin_builds_url, notice: "Build deleted"
  end

  private

  def set_build
    @build = Build.find(params[:id])
  end

  def build_params
    params.require(:build).permit(:title, :description, :url, :icon_emoji,
                                  :status, :kind, :position, :started_on, :finished_on, :cover)
  end
end
