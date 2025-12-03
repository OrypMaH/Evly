class AbacEngine
  def initialize(user)
    @user = user
  end

  def can?(action, resource = nil)
    # Если пользователь не имеет текущей роли - ничего нельзя
    return false unless @user.current_role

    # Ищем подходящее разрешение среди всех ролей пользователя
    @user.current_role.permissions.any? do |permission|
      permission_matches?(permission, action, resource)
    end
  end
  

  private

  def permission_matches?(permission, action, resource)
    normalized_resource = case permission.resource
                       when 'EventDepartment'
                         # Для EventDepartment разрешаем оба типа
                         ['OfferedEventDepartment', 'ApprovedEventDepartment']
                       else
                         [permission.resource]
                       end
    # Проверяем тип ресурса
    return false unless normalized_resource.include?(resource.class.name)
    
    return false unless permission.action == action.to_s
    
    # Проверяем scope (условия)
    evaluate_scope(permission.scope, resource)
  end

  def evaluate_scope(scope, resource)
    case resource
    when Event
      case scope
      when "personal"
        resource.creator == @user || resource.creator.nil?
      else
        false
      end
    when OfferedEventDepartment, ApprovedEventDepartment
      case scope
      when "own_department"
        # Ресурс должен быть в том же подразделении что и пользователь
        resource.department == @user.current_role.department
      when "department_hierarchy"
        resource.department.is_it_ancestor?(@user.current_role.department)
      else
        false # Неизвестный scope
      end
    when Role, Department
      case scope
      when "own_department"
        # Ресурс должен быть в том же подразделении что и пользователь
        resource.department == @user.current_role.department
      when "child_departments"
        resource.department.is_it_ancestor?(@user.current_role.department)
      else
        false # Неизвестный scope
      end
    end
  end
end