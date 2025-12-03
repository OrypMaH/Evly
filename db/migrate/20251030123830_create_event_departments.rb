class CreateEventDepartments < ActiveRecord::Migration[6.1]
  def change
    create_table :event_departments do |t|
      t.bigint :event_id, null: false
      t.bigint :department_id, null: false
      t.timestamps
    end
  end
end