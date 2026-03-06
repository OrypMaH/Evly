class SetDirectionIdNotNullInEvents < ActiveRecord::Migration[6.1]
  def change
    execute <<-SQL
      UPDATE events 
      SET direction_id = (SELECT id FROM directions LIMIT 1) 
      WHERE direction_id IS NULL
    SQL
    
    change_column_null :events, :direction_id, false
    end
end
