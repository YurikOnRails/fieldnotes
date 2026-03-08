class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :cover_url
      t.integer :year_read
      t.integer :rating
      t.text :key_idea
      t.string :status

      t.timestamps
    end
  end
end
