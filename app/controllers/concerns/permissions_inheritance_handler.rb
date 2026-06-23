module PermissionsInheritanceHandler
  extend ActiveSupport::Concern
  included do
    private
    def find_available_departments_for_action(act)
      available_departments = Set.new
      current_user.roles.each do |role|
        role.permissions.where(action: act, resource: 'EventDepartment').each do |permission|
          case permission.scope
          when 'own_department' # Добавляем только подразделение роли
              available_departments.add(role.department) if role.department
          when 'department_hierarchy' # Добавляем всю иерархию: родители + текущее + дети
              if role.department
                  hierarchy_departments = [role.department] + role.department.ancestors + role.department.descendants
                  hierarchy_departments.each do |dept|
                      available_departments.add(dept)
              end
            end
          end
        end
      end
      available_departments.to_a.reject { |dept| @event.departments.include?(dept) }
    end
  end
end