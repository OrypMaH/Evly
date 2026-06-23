module DepartmentResources
    class UsersController < BaseController
        def index
            @department = Department.find(params[:department_id])
            
            authorize_action(:show, @department)
            @users = @department.users

            @user_department_roles = {}
            @users.each do |user|
                @user_department_roles[user.id] = user.roles.where(department: @department)
            end
        end
        
        def edit_roles
            @user = User.find(params[:user_id])
            @department = Department.find(params[:department_id])
            @roles = @department.roles
        end
        def update_roles
            @user = User.find(params[:user_id])
            current_role_ids = @user.role_ids
            
            new_role_ids = params[:user][:role_ids] || []
            new_role_ids = new_role_ids.reject(&:blank?).map(&:to_i)
            
            roles_to_add = new_role_ids - current_role_ids
            roles_to_remove = current_role_ids - new_role_ids
            
            allowed_roles_to_add = roles_to_add.select { |role_id| can?(:assign, Role.find(role_id)) }
            allowed_roles_to_remove = roles_to_remove.select { |role_id| can?(:assign, Role.find(role_id)) }
 
            final_role_ids = current_role_ids - allowed_roles_to_remove + allowed_roles_to_add
            
            if @user.update(role_ids: final_role_ids)
                redirect_to department_user_edit_roles_path(current_department, @user), notice: 'Роли успешно обновлены'
            else
                redirect_to edit_roles_user_path(@user), alert: 'Ошибка при обновлении ролей'
            end
        end
        private
        
        def user_role_params
            params.require(:user).permit(role_ids:[])
        end
    end
end
