class CreateNowEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :now_entries do |t|
      t.datetime :published_at

      t.timestamps
    end
  end
end
