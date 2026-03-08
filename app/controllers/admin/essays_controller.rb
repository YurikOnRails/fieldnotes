class Admin::EssaysController < Admin::BaseController
  before_action :set_essay, only: [:show, :edit, :update, :destroy]

  def index
    @essays = Essay.order(created_at: :desc)
  end

  def show
  end

  def new
    @essay = Essay.new
  end

  def create
    @essay = Essay.new(essay_params)
    if @essay.save
      redirect_to admin_essay_url(@essay), notice: "Essay created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @essay.update(essay_params)
      redirect_to admin_essay_url(@essay), notice: "Essay updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @essay.destroy
    redirect_to admin_essays_url, notice: "Essay deleted"
  end

  private

  def set_essay
    @essay = Essay.find(params[:id])
  end

  def essay_params
    params.require(:essay).permit(:title, :slug, :excerpt, :status, :published_at,
                                  :latitude, :longitude, :location_name, :cover, :content)
  end
end
