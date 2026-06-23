# lib/tasks/directions.rake
namespace :directions do
  desc "Создание направлений воспитательной работы и связывание с мероприятиями"
  task setup: :environment do
    puts "=== Начало создания направлений воспитательной работы ==="
    
    # Проверяем существование подразделения с ID: 2
    department = Department.find_by(id: 2)
    
    unless department
      puts "❌ ОШИБКА: Подразделение с ID=2 не найдено!"
      puts "Создайте сначала подразделение с ID=2 или измените ID в задаче"
      exit 1
    end
    
    puts "✅ Найдено подразделение: #{department.name} (ID: #{department.id})"
    
    # Массив направлений для создания
    directions_data = [
      {
        name: "Гражданственность и патриотизм",
        description: "- отношение к своей стране, малой Родине;\n- правовая культура;\n- чувство долга;\n- отношение к труду."
      },
      {
        name: "Духовность и нравственность личности",
        description: "
        - потребность в самопознании;\n
        - потребность в красоте;\n
        - потребность в общении;\n
        - милосердие и доброта.
        "
      },
      {
        name: "Толерантность",
        description: "
        - способность к состраданию и доброта;\n
        - терпимость и доброжелательность;\n
        - скромность;\n
        - готовность оказать помощь близким и дальним;\n
        - стремление к миру и добрососедству;\n
        - понимание ценности человеческой жизни.
        "
      },
      {
        name: "Спорт и здоровый образ жизни",
        description: "- знание основ здоровьесбережения;\n
        - осознание здоровья как ценности;\n
        - способность к рефлексии;\n
        - занятия физической культурой и спортом."
      },
      {
        name: "Окружающая среда. Культурное наследие и народные традиции.",
        description: "- бережное отношение к природе, земле, животным;\n
        - экологическая культура;\n
        - эстетическое отношение к миру;\n
        - потребность к духовному развитию, реализации творческого потенциала;"
      },
      {
        name: "Общественно-проектная деятельность в соответствии с подходом «Обучение служением»",
        description: "
        - готовность и способность к проектной социально значимой деятельности;\n
        - осознание собственной полезности, инициативности;\n
        - общественная активность обучающихся;\n
        - сознательное отношение к общественно-полезной деятельности.
        "
      },
      {
        name: "Добровольческая (волонтерская) деятельность",
        description: "
        - сознательное отношение к добровольческой (волонтерской)деятельности;\n
        - осознание собственной полезности, инициативности;\n
        - инициативное участие в добровольческой (волонтёрской̆) деятельности, основанной̆на принципах добровольности, бескорыстия и на традициях благотворительности.
        "
      },
      {
        name: "Культурная и творческая деятельность",
        description: "
        - культура самопознания и саморазвития;\n
        - культурно-творческая инициативность;\n
        - вариативность и содержательность досуга.
        "
      }
    ]
    
    created_directions = []
    
    # Создаем направления
    directions_data.each_with_index do |data, index|
      direction = Direction.find_or_create_by(
        name: data[:name],
        department_id: department.id
      ) do |dir|
        dir.description = data[:description]
      end
      
      if direction.persisted?
        created_directions << direction
        puts "#{index + 1}. ✅ Создано направление: #{direction.name}"
      else
        puts "#{index + 1}. ❌ Ошибка создания направления '#{data[:name]}': #{direction.errors.full_messages.join(', ')}"
      end
    end
    
    puts "\n=== Связывание мероприятий с направлениями ==="
    
    # Получаем первое созданное направление
    first_direction = created_directions.first
    
    if first_direction
      # Находим все мероприятия без направления
      events_without_direction = Event.where(direction_id: nil)
      
      if events_without_direction.any?
        updated_count = events_without_direction.update_all(direction_id: first_direction.id)
        puts "✅ Связано #{updated_count} мероприятий с направлением: #{first_direction.name}"
      else
        puts "ℹ️ Все мероприятия уже имеют направление"
      end
      
      # Выводим статистику
      puts "\n=== Статистика ==="
      puts "Всего направлений создано: #{created_directions.count}"
      puts "Всего мероприятий в системе: #{Event.count}"
      puts "Мероприятий с направлением: #{Event.where.not(direction_id: nil).count}"
      puts "Мероприятий без направления: #{Event.where(direction_id: nil).count}"
    else
      puts "❌ Не удалось создать ни одного направления!"
    end
    
    puts "\n=== Задача выполнена ==="
  end
  
  desc "Добавить дополнительные направления"
  task :add, [:department_id] => :environment do |t, args|
    department_id = args[:department_id] || 2
    department = Department.find_by(id: department_id)
    
    unless department
      puts "❌ Подразделение с ID=#{department_id} не найдено!"
      exit 1
    end
    
    puts "Добавление направлений для подразделения: #{department.name}"
    puts "Введите название направления (или 'выход' для завершения):"
    
    loop do
      print "Название: "
      name = STDIN.gets.chomp
      
      break if name.downcase == 'выход' || name.downcase == 'exit'
      
      if name.strip.empty?
        puts "❌ Название не может быть пустым"
        next
      end
      
      # Проверяем, не существует ли уже такое направление
      existing = Direction.find_by(name: name, department_id: department.id)
      if existing
        puts "⚠️ Направление '#{name}' уже существует в этом подразделении"
        next
      end
      
      print "Описание: "
      description = STDIN.gets.chomp
      
      direction = Direction.create(
        name: name,
        description: description,
        department_id: department.id
      )
      
      if direction.persisted?
        puts "✅ Создано направление: #{direction.name}"
      else
        puts "❌ Ошибка: #{direction.errors.full_messages.join(', ')}"
      end
      
      puts "\nВведите следующее название направления (или 'выход'):"
    end
    
    puts "Завершено добавление направлений"
  end
  
  desc "Показать все направления с количеством мероприятий"
  task stats: :environment do
    puts "=== Статистика направлений ==="
    
    Direction.includes(:department, :events).find_each do |direction|
      event_count = direction.events.count
      puts "• #{direction.name}"
      puts "  Подразделение: #{direction.department.name}"
      puts "  Описание: #{direction.description.truncate(50)}"
      puts "  Мероприятий: #{event_count}"
      puts "  Создано: #{direction.created_at.to_date}"
      puts ""
    end
    
    puts "Итого направлений: #{Direction.count}"
    puts "Итого мероприятий с направлением: #{Event.where.not(direction_id: nil).count}"
  end
end