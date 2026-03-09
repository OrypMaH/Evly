class RolesController < ApplicationController
    before_action :authenticate_user!
    before_action :store_referer, only: [:new, :edit, :destroy]
    before_action :set_role, only: [:edit, :update, :show, :destroy, :remove_user, :assign_user]
    
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
        authorize_action(:edit, @role)
        
    end
    def update
        authorize_action(:edit, @role)
        if @role.update role_params
            redirect_to stored_referer || department_path(@role.department),
            notice: 'Роль успешно обновлена'
        else
            render :edit
        end
        
    end
    
    def destroy
        authorize_action(:edit, @role)
        @role.destroy
        redirect_to stored_referer || department_path(@role.department),
        notice: 'Роль успешно обновлена'
    end

    def assign_user
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
        user = User.find(params[:user_id])
        authorize_action(:assign, @role)
        
        user_role = UserRole.find_by(user: user, role: @role)
        if user_role
            user_role.destroy
        end
    end

    private
    def set_role
        @role = Role.find(params[:id])
    end

    def role_params
        params.require(:role).permit(:name,:description,:department_id, permission_ids: [])
    end

end