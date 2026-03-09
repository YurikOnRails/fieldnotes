class Admin::EssaysController < Admin::BaseController
  before_action :set_essay, only: [:edit, :update, :destroy]

  def index
    @essays = Essay.includes(:cover_attachment).order(created_at: :desc)
  end

  def new
    @essay = Essay.new
  end

  def create
    @essay = Essay.new(essay_params)
    apply_publish_intent(@essay)
    if @essay.save
      redirect_to edit_admin_essay_url(@essay), notice: @essay.published? ? "Published!" : "Draft saved"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @essay.assign_attributes(essay_params)
    apply_publish_intent(@essay)
    if @essay.save
      redirect_to edit_admin_essay_url(@essay), notice: @essay.published? ? "Published!" : "Draft saved"
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
    params.require(:essay).permit(:title, :excerpt, :status, :published_at,
                                  :latitude, :longitude, :location_name, :cover, :content)
  end

  def apply_publish_intent(essay)
    return unless params[:commit] == "Publish"
    essay.status = "published"
    essay.published_at ||= Time.current
  end
end
