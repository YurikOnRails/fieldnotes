class CreateExports < ActiveRecord::Migration[8.1]
  def change
    create_table :exports do |t|
      t.datetime :expires_at

      t.timestamps
    end
  end
end
