class AddReadToBook < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :read, :boolean
  end
end
