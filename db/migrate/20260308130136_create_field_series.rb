class CreateFieldSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :field_series do |t|
      t.string :title
      t.string :slug
      t.text :description
      t.string :kind
      t.string :location
      t.date :taken_on
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
    add_index :field_series, :slug, unique: true
  end
end
