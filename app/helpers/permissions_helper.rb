module PermissionsHelper
  def grouped_permissions
    Permission.all.group_by(&:resource).transform_values do |permissions|
      permissions.group_by(&:scope)
    end
  end
  
  def permission_checked?(role, permission)
    role.persisted? ? role.permissions.include?(permission) : false
  end
  
  def format_permission_name(permission)
    action_text = I18n.t("permissions.actions.#{permission.action}", default: permission.action.humanize)
    resource_text = I18n.t("permissions.resources.#{permission.resource}", default: permission.resource.humanize)
    #scope_text = I18n.t("permissions.scopes.#{permission.scope}", default: permission.scope.humanize)
    
    "#{action_text} #{resource_text}" #{scope_text}"
  end

  def format_resource_title(resource)
    I18n.t("permissions.titles.#{resource}", default: resource.humanize)
  end
  def icon_for_resource(resource)
    case resource
        when "Role" then "user secret"
        when "Department" then "sitemap" 
        when "Event" then "calendar"
        when 'Plan' then 'calendar check'
        when 'User' then 'users'
        when 'Direction', 'directions' then 'compass'
    else 
      "setting"
    end
  end
  def scope_icon(scope)
    case scope.to_s
    when 'own_department'
      'building'
    when 'department_hierarchy'
      'sitemap'
    when 'personal'
      'user'
    when 'child_departments'
      'level down'
    else
      'circle'
    end
  end
  
end