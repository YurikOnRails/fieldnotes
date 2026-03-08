class Admin::BuildsController < Admin::BaseController
  before_action :set_build, only: [:show, :edit, :update, :destroy]

  def index
    @builds = Build.ordered
  end

  def show
  end

  def new
    @build = Build.new
  end

  def create
    @build = Build.new(build_params)
    if @build.save
      redirect_to admin_build_url(@build), notice: "Build created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @build.update(build_params)
      redirect_to admin_build_url(@build), notice: "Build updated"
    else
      render :edit, status: :unprocessable_entity
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
    params.require(:build).permit(:title, :slug, :description, :url, :icon_emoji,
                                  :status, :kind, :position, :started_on, :finished_on, :cover)
  end
end
