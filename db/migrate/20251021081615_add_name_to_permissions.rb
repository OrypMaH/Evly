class AddNameToPermissions < ActiveRecord::Migration[6.1]
  def change
    add_column :permissions, :name, :string
    
    # Добавляем индекс для быстрого поиска по имени
    add_index :permissions, :name
    
    # Заполняем существующие записи (если они есть)
    Permission.find_each do |permission|
      permission.update!(name: generate_permission_name(permission))
    end
    
    # Делаем поле обязательным после заполнения
    change_column_null :permissions, :name, false
  end
  
  private
  
  def generate_permission_name(permission)
    # Генерируем человеко-читаемое название
    action = I18n.t("permissions.actions.#{permission.action}", default: permission.action)
    resource = I18n.t("permissions.resources.#{permission.resource}", default: permission.resource.underscore.humanize)
    scope = I18n.t("permissions.scopes.#{permission.scope}", default: permission.scope.humanize)
    
    "#{action} #{resource} (#{scope})"
  end
end
