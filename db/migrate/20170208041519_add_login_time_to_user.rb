class AddLoginTimeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_login_time, :string
  end
end
