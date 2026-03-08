class CreateFieldItems < ActiveRecord::Migration[8.1]
  def change
    create_table :field_items do |t|
      t.references :field_series, null: false, foreign_key: true
      t.string :kind
      t.text :caption
      t.integer :position
      t.string :youtube_url

      t.timestamps
    end
  end
end
