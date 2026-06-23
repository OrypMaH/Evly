# rails generate migration AddLevelAndDetailsToEvents
class AddLevelAndDetailsToEvents < ActiveRecord::Migration[6.1]
  def change
    add_reference :events, :event_level, foreign_key: true
    add_column :events, :format, :string
    add_column :events, :location, :string
    
  end
end
