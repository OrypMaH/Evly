# lib/tasks/add_default_responsible_person.rake
namespace :events do
  desc "Добавляет ответственное лицо по умолчанию (пользователь ID=1 с его первой ролью) для мероприятий без ответственных"
  task add_default_responsible_person: :environment do
    puts "=" * 80
    puts "🚀 Запуск задачи: добавление ответственного лица по умолчанию"
    puts "=" * 80
    
    # Находим пользователя по умолчанию
    default_user = User.find_by(id: 1)
    
    unless default_user
      puts "❌ ОШИБКА: Пользователь с ID=1 не найден!"
      exit 1
    end
    
    # Получаем первую роль пользователя
    default_role = default_user.roles.first
    
    unless default_role
      puts "❌ ОШИБКА: У пользователя #{default_user.full_name} (ID=1) нет ни одной роли!"
      exit 1
    end
    
    puts "📊 Параметры по умолчанию:"
    puts "   Пользователь: #{default_user.full_name} (ID: #{default_user.id})"
    puts "   Роль: #{default_role.name} (ID: #{default_role.id})"
    puts "=" * 80
    
    # Находим все мероприятия без ответственных лиц
    events_without_responsible = Event.left_joins(:responsible_people)
                                      .where(responsible_people: { id: nil })
                                      .distinct
    
    total_events = events_without_responsible.count
    puts "📊 Найдено мероприятий без ответственных лиц: #{total_events}"
    
    if total_events.zero?
      puts "✅ Все мероприятия уже имеют ответственных лиц!"
      exit 0
    end
    
    # Статистика для отчета
    stats = {
      processed: 0,
      skipped: 0,
      errors: 0
    }
    
    puts "\n🔄 Начинаем обработку..."
    
    events_without_responsible.find_each.with_index do |event, index|
      print "\r⏳ Обработано: #{index + 1}/#{total_events}"
      
      begin
        # Проверяем, не появилось ли у мероприятия ответственное лицо
        # (на случай параллельной обработки)
        if event.responsible_people.exists?
          stats[:skipped] += 1
          next
        end
        
        # Создаем ответственное лицо
        responsible_person = event.responsible_people.create!(
          user_id: default_user.id,
          role_id: default_role.id
        )
        
        stats[:processed] += 1
        
        # Логируем каждое 10-е мероприятие для контроля
        if (stats[:processed] % 10).zero?
          puts "\n   ✅ Создано #{stats[:processed]} ответственных лиц"
        end
        
      rescue => e
        stats[:errors] += 1
        puts "\n   ❌ Ошибка для мероприятия ID=#{event.id}: #{e.message}"
      end
    end
    
    puts "\n\n" + "=" * 80
    puts "📊 ИТОГОВАЯ СТАТИСТИКА:"
    puts "   Всего мероприятий без ответственных: #{total_events}"
    puts "   ✅ Создано: #{stats[:processed]}"
    puts "   ⏭️  Пропущено (уже есть): #{stats[:skipped]}"
    puts "   ❌ Ошибок: #{stats[:errors]}"
    puts "=" * 80
    
  end
  
end