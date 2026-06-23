class FillMissingDatesInEvents < ActiveRecord::Migration[6.1]
  def up
    # Обновляем start_date, если он nil - устанавливаем created_at
    Event.where(start_date: nil).update_all("start_date = created_at")
    
    # Обновляем end_date, если он nil - устанавливаем сегодняшнюю дату
    Event.where(end_date: nil).update_all("end_date = CURRENT_DATE")
  end
end
