class CreatePageViews < ActiveRecord::Migration[8.1]
  def change
    create_table :page_views do |t|
      t.string :event
      t.json :payload

      t.timestamps
    end
  end
end
