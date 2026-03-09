class Admin::ProfilesController < Admin::BaseController
  def edit
    @profile = Profile.instance
  end

  def update
    @profile = Profile.instance
    if @profile.update(profile_params)
      redirect_to edit_admin_profile_path, notice: "Profile updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :bio, :avatar)
  end
end
