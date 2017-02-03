class AddBatchToBook < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :batch, :boolean, default: false
  end
end
