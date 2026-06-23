# lib/tasks/levels.rake
namespace :levels do
  desc "Создание всех уровней мероприятий"
  task setup: :environment do
    puts "=== Начало создания уровней мероприятий ==="
    
    levels_data = [
      { name: 'Кафедральный', priority: 1, description: 'Уровень кафедры' },
      { name: 'Факультетский', priority: 6, description: 'Уровень факультета' },
      { name: 'Внутривузовский', priority: 11, description: 'Уровень учебного заведения' },
      { name: 'Городской', priority: 16, description: 'Городской уровень' },
      { name: 'Муниципальный', priority: 21, description: 'Муниципальный уровень' },
      { name: 'Региональный', priority: 26, description: 'Региональный уровень' },
      { name: 'Всероссийский', priority: 31, description: 'Всероссийский уровень' },
      { name: 'Международный', priority: 36, description: 'Международный уровень' }
    ]
    
    created_count = 0
    updated_count = 0
    
    levels_data.each do |level_data|
      level = EventLevel.find_by(name: level_data[:name])
      
      if level
        if level.update(level_data)
          updated_count += 1
          puts "✓ Обновлен: #{level_data[:name]}"
        else
          puts "✗ Ошибка обновления #{level_data[:name]}: #{level.errors.full_messages.join(', ')}"
        end
      else
        level = EventLevel.new(level_data)
        if level.save
          created_count += 1
          puts "✓ Создан: #{level_data[:name]}"
        else
          puts "✗ Ошибка создания #{level_data[:name]}: #{level.errors.full_messages.join(', ')}"
        end
      end
    end
    
    puts "=== Итог ==="
    puts "Всего уровней в базе: #{EventLevel.count}"
    puts "Создано: #{created_count}"
    puts "Обновлено: #{updated_count}"
    puts "=== Завершено ==="
  end
  
  desc "Показать все уровни мероприятий"
  task list: :environment do
    puts "=== Список уровней мероприятий ==="
    
    EventLevel.order(:priority).each do |level|
      puts "#{level.id}. #{level.name} (приоритет: #{level.priority})"
      puts "   Описание: #{level.description}" if level.description.present?
    end
    
    puts "=== Всего: #{EventLevel.count} уровней ==="
  end
  
  desc "Удалить все уровни мероприятий"
  task clear: :environment do
    print "Вы уверены, что хотите удалить ВСЕ уровни мероприятий? (yes/no): "
    answer = STDIN.gets.chomp
    
    if answer.downcase == 'yes'
      count = EventLevel.count
      EventLevel.destroy_all
      puts "Удалено #{count} уровней мероприятий"
    else
      puts "Операция отменена"
    end
  end
  
  desc "Сбросить приоритеты уровней (вернуть значения по умолчанию)"
  task reset_priorities: :environment do
    puts "=== Сброс приоритетов уровней ==="
    
    priority_map = {
      'Кафедральный' => 1,
      'Факультетский' => 2,
      'Внутривузовский' => 3,
      'Городской' => 4,
      'Муниципальный' => 5,
      'Региональный' => 6,
      'Всероссийский' => 7,
      'Международный' => 8
    }
    
    updated_count = 0
    
    priority_map.each do |name, priority|
      level = EventLevel.find_by(name: name)
      if level && level.update(priority: priority)
        updated_count += 1
        puts "✓ Обновлен приоритет: #{name} → #{priority}"
      end
    end
    
    puts "=== Обновлено: #{updated_count} уровней ==="
  end
  
  desc "Полная настройка уровней (очистка + создание)"
  task full_reset: :environment do
    puts "=== Полная перезагрузка уровней мероприятий ==="
    
    # Сначала очищаем
    Rake::Task['levels:clear'].invoke
    
    # Потом создаем заново
    Rake::Task['levels:setup'].invoke
    
    # Проверяем
    Rake::Task['levels:check'].invoke
  end
  
  desc "Назначить уровень по умолчанию мероприятиям без уровня"
  task assign_default: :environment do
    puts "=== Назначение уровня по умолчанию мероприятиям ==="
    
    default_level = EventLevel.find_by(name: 'Внутривузовский')
    
    unless default_level
      puts "✗ Уровень 'Внутривузовский' не найден. Сначала выполните levels:setup"
      next
    end
    
    orphaned_events = Event.where(event_level_id: nil)
    count = orphaned_events.count
    
    if count > 0
      updated = orphaned_events.update_all(event_level_id: default_level.id)
      puts "✓ Назначен уровень по умолчанию #{default_level.name} для #{updated} мероприятий"
    else
      puts "✓ Нет мероприятий без уровня"
    end
  end
end