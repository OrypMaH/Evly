namespace :db do
  desc "Безопасная очистка таблиц users, roles, user_roles (только development/test)"
  task reset_users_roles: :environment do
    # Проверка среды
    unless Rails.env.development? || Rails.env.test?
      puts "❌ ОПАСНОСТЬ! Эту задачу можно запускать ТОЛЬКО в development или test среде!"
      puts "   Текущая среда: #{Rails.env}"
      exit 1
    end

    # Подтверждение действия
    puts "⚠️  ВНИМАНИЕ: Это удалит ВСЕ данные из таблиц:"
    puts "   - users (#{User.count} записей)"
    puts "   - roles (#{Role.count} записей)" 
    puts "   - user_roles (#{UserRole.count} записей)"
    puts ""
    print "❓ Вы уверены? (введите 'YES' для подтверждения): "
    
    confirmation = $stdin.gets.chomp
    unless confirmation == 'YES'
      puts "❌ Отменено пользователем"
      exit 0
    end

    # Выполнение очистки
    puts ""
    puts "🔄 Начинаем очистку..."
    
    start_time = Time.current
    tables_data = {
      'user_roles' => UserRole.count,
      'users' => User.count,
      'roles' => Role.count
    }

    # Очистка в правильном порядке (из-за foreign keys)
    UserRole.delete_all
    User.delete_all
    Role.delete_all

    # Сброс sequences для PostgreSQL
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      ActiveRecord::Base.connection.reset_pk_sequence!('user_roles')
      ActiveRecord::Base.connection.reset_pk_sequence!('users')
      ActiveRecord::Base.connection.reset_pk_sequence!('roles')
      puts "✅ Sequences сброшены"
    end

    # Статистика
    duration = Time.current - start_time
    puts ""
    puts "✅ Очистка завершена за #{duration.round(2)}с"
    puts "📊 Удалено записей:"
    tables_data.each { |table, count| puts "   - #{table}: #{count}" }
    
    # Создание тестового пользователя (опционально)
    create_core if Rails.env.development?
    create_basic_system if Rails.env.development?
  end

  private

  def create_core
    return if User.exists?
    
    puts ""
    puts "Конфигурация исходного состояния системы..."
    
    core_department = Department.find_or_create_by!(
      parent_id: nil,
      name: 'Корневое подразделение'
    )
    
    core_role = Role.find_or_create_by!(
      name: 'admin', 
      department: core_department
    )

    # Создаем тестового пользователя
    core_user = User.create!(
      surname: 'Админов',
      name: 'Админ',
      patronymic: 'Админович',
      password: 'pa$$word',
      password_confirmation: 'pa$$word'
    )
    
    core_user.roles << [core_role]
    core_user.update!(current_role: core_role)
  end
  def create_basic_system
    
    test_user = User.create!(
      surname: 'Иванов',
      name: 'Иван',
      patronymic: 'Иванович',
      password: 'userpass',
      password_confirmation: 'userpass'
    )
    first_department = Department.find_or_create_by!(
      name: 'АмГУ',
      description: 'Амурский государственный университет'
    )
  end
end