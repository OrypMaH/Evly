class CreatePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :plans do |t|
      t.string :title, null: false
      t.text :description
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :department, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      
      t.timestamps
    end
  end
end