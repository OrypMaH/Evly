# db/migrate/XXXXXXXXXXXXXX_add_direction_reference_to_events.rb
class AddDirectionReferenceToEvents < ActiveRecord::Migration[6.1]
  def change
    # Добавляем колонку с проверкой
    unless column_exists?(:events, :direction_id)
      add_column :events, :direction_id, :bigint
    end
    
    # Добавляем внешний ключ с проверкой
    unless foreign_key_exists?(:events, :directions)
      add_foreign_key :events, :directions
    end
    
    # Добавляем индекс с уникальным именем
    unless index_exists?(:events, :direction_id)
      add_index :events, :direction_id, name: 'index_events_direction_id'
    end
  end
end