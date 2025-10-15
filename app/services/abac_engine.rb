class AbacEngine
  def initialize(user)
    @user = user
  end

  def can?(action, resource = nil)
    # Если пользователь не имеет текущей роли - ничего нельзя
    return false unless @user.current_role

    # Ищем подходящее разрешение среди всех ролей пользователя
    @user.roles.any? do |role|
      role.permissions.any? do |permission|
        permission_matches?(permission, action, resource)
      end
    end
  end

  private

  def permission_matches?(permission, action, resource)
    # Проверяем действие
    return false unless permission.action == action.to_s
    
    # Проверяем тип ресурса
    return false unless permission.resource == resource.class.name
    
    # Проверяем scope (условия)
    evaluate_scope(permission.scope, resource)
  end

  def evaluate_scope(scope, resource)
    case scope
    when "own_department"
      # Ресурс должен быть в том же подразделении что и пользователь
      resource.department == @user.current_role.department
    when "all"
      true  # Без ограничений
    else
      false # Неизвестный scope
    end
  end
end