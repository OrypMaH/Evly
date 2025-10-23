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