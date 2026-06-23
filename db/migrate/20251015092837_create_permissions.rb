class CreatePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions do |t|
      t.string :action, null: false        # "create", "update", "delete", "assign"
      t.string :resource, null: false      # "Role", "Department", "Event" 
      t.string :scope, null: false         # "own_department", "sub_departments", "same_hierarchy", "all"
      t.timestamps
    end

    create_table :role_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.timestamps
    end
  end
end
