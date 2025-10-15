class RolesController < ApplicationController
    before_action :authenticate_user!
    def index
        if current_user.current_role
            @roles = current_user.roles
        else
            @roles = []
        end
    end
    def destroy
        @role = Role.find_by id: params[:id]
        @role.destroy
        redirect_to roles_path
    end
    def edit
        @role = Role.find_by id: params[:id]
    end
    def update
        @role = Role.find_by id: params[:id]
        if @role.update role_params
            redirect_to roles_path
        else
            render :index
        end
    end
    def new
        @role = Role.new(department_id: params[:department_id])
        authorize_action(:create, @role)
    end
    def create
        @role=Role.new role_params
        authorize_action(:create, @role)
        if @role.save
            redirect_to roles_path
        else 
            render :new
        end
    end
    def assign_user
        @role = Role.find(params[:id])
        user = User.find(params[:user_id])
        
        if @role.users.include?(user)
        render json: { success: false, message: "Пользователь уже имеет эту роль" }
        else
        @role.users << user
        render json: { success: true, message: "Роль назначена пользователю #{user.full_name}" }
        end
    rescue ActiveRecord::RecordNotFound
        render json: { success: false, message: "Пользователь не найден" }, status: :not_found
    end
    def remove_user
        @role = Role.find(params[:id])
        user = User.find(params[:user_id])
        
        if @role.users.include?(user)
            @role.users.delete(user)
            render json: { success: true, message: "Роль снята с пользователя #{user.full_name}" }
        else
            render json: { success: false, message: "Пользователь не имеет этой роли" }
        end
    end
    private
    def role_params
        params.require(:role).permit(:name,:description,:department_id)
    end
    
    def authorize_action(action, resource)
        unless AbacEngine.new(current_user).can?(action, resource)
        redirect_to root_path, alert: "Доступ запрещен"
        end
    end
end