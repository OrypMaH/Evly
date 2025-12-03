class AddCreatorToEvents < ActiveRecord::Migration[6.1]
  def change
    add_reference :events, :creator, foreign_key: { to_table: :users }

    reversible do |dir|
      dir.up do
        root_user_id = 1
        
        Event.update_all(creator_id: root_user_id)
        
        change_column_null :events, :creator_id, false
      end
    end
  end
end