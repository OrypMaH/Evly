namespace :permissions do
  desc "Create test permissions and assign to roles"
  task basicsetup: :environment do
    puts "🎯 Setting up permissions system..."
    
    # 1. Создаем разрешение
    create_role_permission = Permission.find_or_create_by!(
      action: "create",
      resource: "Role", 
      scope: "own_department"
    )
    puts "✅ Permission: #{create_role_permission.action} #{create_role_permission.resource}"

    # 2. Находим или создаем роль "Глава подразделения"
    core_role = Role.find_by!(
      id: "1"
    ) 

    # 3. Связываем разрешение с ролью
    unless core_role.permissions.include?(create_role_permission)
      core_role.permissions << create_role_permission
      puts "✅ Assigned permission to core_role"
    end
  end
  task add_plan_permissions: :environment do
    puts "Добавление прав для планов (Plan)..."
    
    plan_permissions = [
      # Права на планы в своем подразделении
      { action: "create", resource: "Plan", scope: "own_department" },
      { action: "edit", resource: "Plan", scope: "own_department" },
      { action: "delete", resource: "Plan", scope: "own_department" },
      { action: "show", resource: "Plan", scope: "own_department" },
      { action: "manage", resource: "Plan", scope: "own_department" },
      
      # Права на планы в дочерних подразделениях
      { action: "create", resource: "Plan", scope: "child_departments" },
      { action: "edit", resource: "Plan", scope: "child_departments" },
      { action: "delete", resource: "Plan", scope: "child_departments" },
      { action: "show", resource: "Plan", scope: "child_departments" },
      { action: "manage", resource: "Plan", scope: "child_departments" },
      
      # Права на управление мероприятиями внутри плана
      { action: "add_event", resource: "Plan", scope: "own_department" },
      { action: "remove_event", resource: "Plan", scope: "own_department" },
      { action: "reorder_events", resource: "Plan", scope: "own_department" },
      
      { action: "add_event", resource: "Plan", scope: "child_departments" },
      { action: "remove_event", resource: "Plan", scope: "child_departments" },
      { action: "reorder_events", resource: "Plan", scope: "child_departments" }
    ]
    
    core_role = Role.find_by!(id: "1")
    
    plan_permissions.each do |perm|
      permission = Permission.find_or_create_by!(perm)
      unless core_role.permissions.include?(permission)
        core_role.permissions << permission
        puts "Добавлено разрешение: #{perm[:action]} #{perm[:resource]} (#{perm[:scope]})"
      else
        puts "Разрешение уже существует: #{perm[:action]} #{perm[:resource]} (#{perm[:scope]})"
      end
    end
    
    puts "Добавлено #{plan_permissions.count} разрешений для Plan"
    puts "Всего разрешений у роли: #{core_role.permissions.count}"
  end
  task redo_plan_permissions: :environment do
    puts "Перенастройка разрешений для планов и департаментов..."
    
    # Находим роль
    core_role = Role.find_by!(id: "1")
    
    # Последние 6 разрешений, которые нужно удалить
    permissions_to_remove = [
      { action: "add_event", resource: "Plan", scope: "own_department" },
      { action: "remove_event", resource: "Plan", scope: "own_department" },
      { action: "reorder_events", resource: "Plan", scope: "own_department" },
      { action: "add_event", resource: "Plan", scope: "child_departments" },
      { action: "remove_event", resource: "Plan", scope: "child_departments" },
      { action: "reorder_events", resource: "Plan", scope: "child_departments" }
    ]
    
    # Удаляем старые разрешения у роли
    permissions_to_remove.each do |perm_attrs|
      permission = Permission.find_by(perm_attrs)
      if permission && core_role.permissions.include?(permission)
        permission.destroy
        puts "Удалено разрешение: #{perm_attrs[:action]} #{perm_attrs[:resource]} (#{perm_attrs[:scope]})"
        
      else
        puts "Разрешение не найдено: #{perm_attrs[:action]} #{perm_attrs[:resource]} (#{perm_attrs[:scope]})"
      end
    end
    
    # Создаем новые разрешения для Department
    department_permissions = [
      { action: "add_event", resource: "Department", scope: "own_department" },
      { action: "remove_event", resource: "Department", scope: "own_department" },
      { action: "reorder_events", resource: "Department", scope: "own_department" },
      { action: "add_event", resource: "Department", scope: "child_departments" },
      { action: "remove_event", resource: "Department", scope: "child_departments" },
      { action: "reorder_events", resource: "Department", scope: "child_departments" }
    ]
    
    # Добавляем новые разрешения
    department_permissions.each do |perm|
      permission = Permission.find_or_create_by!(perm)
      unless core_role.permissions.include?(permission)
        core_role.permissions << permission
        puts "Добавлено новое разрешение: #{perm[:action]} #{perm[:resource]} (#{perm[:scope]})"
      else
        puts "Разрешение уже существует: #{perm[:action]} #{perm[:resource]} (#{perm[:scope]})"
      end
    end
    
    puts "Готово! Удалено #{permissions_to_remove.count} старых разрешений."
    puts "Добавлено #{department_permissions.count} новых разрешений для Department."
    puts "Всего разрешений у роли: #{core_role.permissions.count}"
  end
  task fullsetup: :environment do
    permissions = [
      { action: "create", resource: "Event", scope: "own_department" },
      { action: "edit", resource: "Event", scope: "own_department" },
      { action: "delete", resource: "Event", scope: "own_department" },
      { action: "show", resource: "Event", scope: "own_department" },
      { action: "create", resource: "Role", scope: "own_department" },
      { action: "edit", resource: "Role", scope: "own_department" },
      { action: "delete", resource: "Role", scope: "own_department" },
      { action: "show", resource: "Role", scope: "own_department" },
      { action: "assign", resource: "Role", scope: "own_department" },
      { action: "create", resource: "Role", scope: "child_departments" },
      { action: "edit", resource: "Role", scope: "child_departments" },
      { action: "delete", resource: "Role", scope: "child_departments" },
      { action: "show", resource: "Role", scope: "child_departments" },
      { action: "assign", resource: "Role", scope: "child_departments" },
      { action: "create", resource: "Department", scope: "own_department" },
      { action: "edit", resource: "Department", scope: "own_department" },
      { action: "delete", resource: "Department", scope: "own_department" },
      { action: "show", resource: "Department", scope: "own_department" },
      { action: "create", resource: "Department", scope: "child_departments" },
      { action: "edit", resource: "Department", scope: "child_departments" },
      { action: "delete", resource: "Department", scope: "child_departments" },
      { action: "show", resource: "Department", scope: "child_departments" }
    ]
    core_role = Role.find_by!(
      id: "1"
    )
    permissions.each do |perm|
      core_role.permissions << Permission.find_or_create_by!(perm)
    end
  end

  task planevent: :environment do
    core_role = Role.find_by!(
      id: "1"
    )
    permissions_to_remove = [
      { action: "create", resource: "PlanEvent", scope: "own_departments" }
    ]
    
    # Удаляем старые разрешения
    permissions_to_remove.each do |perm_attrs|
      permission = Permission.find_by(perm_attrs)
      if permission && core_role.permissions.include?(permission)
        permission.destroy
        puts "Удалено разрешение: #{perm_attrs[:action]} #{perm_attrs[:resource]} (#{perm_attrs[:scope]})"
        
      else
        puts "Разрешение не найдено: #{perm_attrs[:action]} #{perm_attrs[:resource]} (#{perm_attrs[:scope]})"
      end
    end
    permissions = [
      { action: "create", resource: "PlanEvent", scope: "own_department" }
    ]
    permissions.each do |perm|
      core_role.permissions << Permission.find_or_create_by!(perm)
    end
  end

  task event_permissions: :environment do
    puts "Обновление разрешений для мероприятий..."
    
    event_permissions = [
      # Базовые права на мероприятие
      { action: "create", resource: "Event", scope: "personal" },
      { action: "view", resource: "Event", scope: "personal" },
      { action: "edit", resource: "Event", scope: "personal" },
      { action: "delete", resource: "Event", scope: "personal" },
      
      # Иерархическое управление мероприятиями
      { action: "manage", resource: "Event", scope: "department_hierarchy" }
    ]

    event_department_permissions = [
      # Низкий уровень: предложение участия
      { action: "offer", resource: "EventDepartment", scope: "own_department" },
      { action: "offer", resource: "EventDepartment", scope: "department_hierarchy" },
      
      # Высокий уровень: прямое назначение
      { action: "assign", resource: "EventDepartment", scope: "own_department" },
      { action: "assign", resource: "EventDepartment", scope: "child_departments" },
      
      # Утверждение/отклонение участия
      { action: "approve", resource: "EventDepartment", scope: "own_department" },
      { action: "reject", resource: "EventDepartment", scope: "own_department" },
      
      # Просмотр участий в иерархии
      { action: "view", resource: "EventDepartment", scope: "department_hierarchy" }
    ]

    core_role = Role.find_by!(id: "1")
    
    # Удаляем только старые разрешения Event
    old_event_permissions = Permission.where(resource: "Event")
    if old_event_permissions.any?
      core_role.permissions.delete(old_event_permissions)
      puts "Удалено старых разрешений Event: #{old_event_permissions.count}"
      old_event_permissions.destroy_all
    end

    # Добавляем новые
    event_permissions.each do |perm|
      permission = Permission.find_or_create_by!(perm)
      core_role.permissions << permission unless core_role.permissions.include?(permission)
      puts "Добавлено разрешение: #{perm[:action]} #{perm[:resource]} (#{perm[:scope]})"
    end
    
    event_department_permissions.each do |perm|
      permission = Permission.find_or_create_by!(perm)
      core_role.permissions << permission unless core_role.permissions.include?(permission)
      puts "Добавлено разрешение: #{perm[:action]} #{perm[:resource]} (#{perm[:scope]})"
    end

    puts "Обновление завершено! Добавлено #{event_permissions.count+event_department_permissions.count} новых разрешений для Event"
  end


  desc "Show current permissions state"
  task status: :environment do
    puts "📊 Current Permissions Status:"
    puts ""

    Permission.all.each do |permission|
      puts "🔹 #{permission.action} #{permission.resource} (#{permission.scope})"
      permission.roles.each do |role|
        puts "   └── Назначено роли: #{role.name} (Подразделение: #{role.department&.name})"
      end
      puts ""
    end

    puts "👥 Users with permissions:"
    User.joins(roles: :permissions).distinct.each do |user|
      puts "🔸 #{user.full_name} (#{user.email})"
      user.roles.each do |role|
        role.permissions.each do |permission|
          puts "   └── Может: #{permission.action} #{permission.resource}"
        end
      end
    end
  end

  desc "Clear all permissions data"
  task clear: :environment do
    Permission.destroy_all
    puts "🧹 All permissions cleared"
  end
end