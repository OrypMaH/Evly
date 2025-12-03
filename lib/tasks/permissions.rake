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