class RolesController < ApplicationController
    before_action :authenticate_user!
    before_action :store_referer, only: [:new, :edit]
    
    def new
        @role = Role.new(department_id: params[:department_id], permission_ids: params[:permission_ids])
        authorize_action(:create, @role)
    end

    def create
        @role=Role.new role_params
        authorize_action(:create, @role)
        if @role.save
            redirect_to stored_referer || department_path(@role.department),
            notice: 'Роль успешно создана'
        else 
            render :new
        end
    end

    def edit
        @role = Role.find_by id: params[:id]
        authorize_action(:edit, @role)
        
    end
    def update
        @role = Role.find_by id: params[:id]
        authorize_action(:edit, @role)
        if @role.update role_params
            redirect_to stored_referer || department_path(@role.department),
            notice: 'Роль успешно обновлена'
        else
            render :edit
        end
        
    end
    
    def destroy
        @role = Role.find_by id: params[:id]
        authorize_action(:edit, @role)
        @role.destroy
        redirect_to roles_path
    end
    
    def index
        if current_user.current_role
            @roles = current_user.roles
        else
            @roles = []
        end
    end

    def assign_user
        @role = Role.find(params[:id])
        authorize_action(:assign, @role)
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
        authorize_action(:assign, @role)
        
        if @role.users.include?(user)
            @role.users.delete(user)
            render json: { success: true, message: "Роль снята с пользователя #{user.full_name}" }
        else
            render json: { success: false, message: "Пользователь не имеет этой роли" }
        end
    end
    private

    

    def role_params
        params.require(:role).permit(:name,:description,:department_id, permission_ids: [])
    end
end