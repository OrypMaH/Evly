class CreatePlanEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :plan_events do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :event_department, null: false, foreign_key: { to_table: :approved_event_departments }
      t.integer :position
      
      t.timestamps
    end
  end
end