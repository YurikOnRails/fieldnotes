class CreateSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      t.boolean :watermark_enabled, default: false, null: false
      t.string  :watermark_position, default: "bottom_right"
      t.integer :watermark_opacity, default: 30

      t.timestamps
    end
  end
end
