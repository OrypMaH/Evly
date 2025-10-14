class AddDepartmentToRoles < ActiveRecord::Migration[6.1]
  def change
    add_reference :roles, :department, foreign_key: true
    
    # Создаем корневое подразделение и переносим существующие роли
    reversible do |dir|
      dir.up do
        # Создаем корневое подразделение
        root_dept = Department.create!(name: 'Корневое подразделение', description: 'Автоматически созданное корневое подразделение')
        
        # Привязываем все существующие роли к корневому подразделению
        Role.update_all(department_id: root_dept.id)
        
        # Делаем department_id обязательным для новых ролей
        change_column_null :roles, :department_id, false
      end
    end
  end
end