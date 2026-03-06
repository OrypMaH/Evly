# rails generate migration CreateEventLevels
class CreateEventLevels < ActiveRecord::Migration[6.1]
  def change
    create_table :event_levels do |t|
      t.string :name, null: false
      t.integer :priority, default: 0 # для сортировки
      t.string :description
      
      t.timestamps
    end
    add_index :event_levels, :priority
  end
end