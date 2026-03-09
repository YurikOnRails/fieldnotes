class Admin::SettingsController < Admin::BaseController
  before_action :set_setting

  def edit
    render Views::Admin::Settings::EditView.new(setting: @setting)
  end

  def update
    if @setting.update(setting_params)
      redirect_to edit_admin_settings_path, notice: "Settings saved"
    else
      render Views::Admin::Settings::EditView.new(setting: @setting), status: :unprocessable_entity
    end
  end

  def regenerate_watermarks
    count = 0
    FieldItem.includes(:photo_attachment).find_each do |item|
      next unless item.photo.attached?
      ImageVariantJob.perform_later(item, watermark: true)
      count += 1
    end
    redirect_to edit_admin_settings_path, notice: "Queued watermark regeneration for #{count} photo(s)"
  end

  private

  def set_setting
    @setting = SiteSetting.current
  end

  def setting_params
    params.require(:site_setting).permit(
      :watermark_enabled, :watermark_position, :watermark_opacity, :watermark
    )
  end
end
