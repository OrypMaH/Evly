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
    end
end
