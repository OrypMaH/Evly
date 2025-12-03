# Миграция для расширения EventDepartment
class EnhanceEventDepartments < ActiveRecord::Migration[6.1]
  def change
    add_column :event_departments, :status, :integer, default: 0, null: false
    add_column :event_departments, :participants_count, :integer, default: 0
    add_column :event_departments, :proposed_by_user_id, :bigint
    add_column :event_departments, :approved_by_user_id, :bigint
    add_column :event_departments, :approved_at, :datetime
    
    add_foreign_key :event_departments, :users, column: :proposed_by_user_id
    add_foreign_key :event_departments, :users, column: :approved_by_user_id
    
    add_index :event_departments, :status
  end
end