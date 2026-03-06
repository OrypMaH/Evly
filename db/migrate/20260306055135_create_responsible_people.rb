class CreateResponsiblePeople < ActiveRecord::Migration[6.1]
  def change
    create_table :responsible_people do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
      
      t.index [:event_id, :user_id], unique: true, 
        name: 'idx_responsible_people_on_event_user'
    end
  end
end
