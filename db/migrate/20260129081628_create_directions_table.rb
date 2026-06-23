# db/migrate/XXXXXXXXXXXXXX_create_directions_table.rb
class CreateDirectionsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :directions do |t|
      t.string :name, null: false
      t.text :description
      t.references :department, null: false, foreign_key: true
      
      t.timestamps
      
      t.index [:department_id, :name], unique: true
    end
  end
end
