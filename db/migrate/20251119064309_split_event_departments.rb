class SplitEventDepartments < ActiveRecord::Migration[6.1]
 def change
    create_table :offered_event_departments do |t|
      t.bigint :event_id, null: false
      t.bigint :department_id, null: false
      t.bigint :proposed_by_user_id, null: false
      t.datetime :proposed_at
      t.timestamps
    end

     create_table :approved_event_departments do |t|
      t.bigint :event_id, null: false
      t.bigint :department_id, null: false
      t.bigint :approved_by_user_id, null: false
      t.integer :participants_count, default: 1, null: false
      t.datetime :approved_at
      t.timestamps
    end

     drop_table :event_departments
  end
end
