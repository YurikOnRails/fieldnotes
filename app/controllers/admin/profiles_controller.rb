class Admin::ProfilesController < Admin::BaseController
  def edit
    @profile = Profile.instance
    render Views::Admin::Profiles::EditView.new(profile: @profile)
  end

  def update
    @profile = Profile.instance
    if @profile.update(profile_params)
      redirect_to edit_admin_profile_path, notice: "Profile updated"
    else
      render Views::Admin::Profiles::EditView.new(profile: @profile), status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :bio, :avatar)
  end
end
