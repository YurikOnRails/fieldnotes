class CreateBuilds < ActiveRecord::Migration[8.1]
  def change
    create_table :builds do |t|
      t.string :title
      t.string :slug
      t.text :description
      t.string :url
      t.string :icon_emoji
      t.string :status
      t.string :kind
      t.integer :position
      t.date :started_on
      t.date :finished_on

      t.timestamps
    end
    add_index :builds, :slug, unique: true
  end
end
