class AddCurrentRoleIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :current_role_id, :bigint
    add_foreign_key :users, :roles, column: :current_role_id
  end
end
