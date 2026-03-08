class CreateEssays < ActiveRecord::Migration[8.1]
  def change
    create_table :essays do |t|
      t.string :title
      t.string :slug
      t.text :excerpt
      t.string :status
      t.datetime :published_at
      t.decimal :latitude
      t.decimal :longitude
      t.string :location_name

      t.timestamps
    end
    add_index :essays, :slug, unique: true
  end
end
