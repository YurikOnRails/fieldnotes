class AddStatusToExports < ActiveRecord::Migration[8.1]
  def change
    add_column :exports, :status, :string
  end
end
