class RolesController < ApplicationController
    before_action :authenticate_user!
    before_action :store_referer, only: [:new, :edit, :destroy, :remove_user, :assign_user]
    before_action :set_role, only: [:edit, :update, :show, :destroy, :remove_user, :assign_user]
    
    def new
        @role = Role.new(department_id: params[:department_id], permission_ids: params[:permission_ids])
        if can?(:create, @role)

        else
            @role = nil
            redirect_to stored_referer || department_path(current_department)
            flash[:error] = "Нет доступа" 
        end
    end

    def create
        @role=Role.new(role_params)
        if can?(:create, @role)
            if @role.save
                redirect_to department_path(@role.department),
                notice: 'Роль успешно создана'
            else 
                render :new
            end
        else
            flash[:error] = "Нет доступа" 
        end
    end

    def edit
        authorize_action(:edit, @role)
        
    end

    def update
        if can?(:edit, @role)
            if @role.update role_params.except(:department_id)
                redirect_to stored_referer || department_path(@role.department),
                notice: 'Роль успешно обновлена'
            else
                render :edit
            end
        else
            @role = nil
            redirect_to stored_referer || department_path(current_department)
            flash[:error] = "Нет доступа" 
        end
        
    end
    
    def destroy
        if can?(:delete, @role)
            @role.destroy
            redirect_to stored_referer || department_path(@role.department)
            flash[:warning] = "Роль #{@role.name} успешно удалена"
        end
    end

    def assign_user
        if can?(:assign, @role)
            user = User.find(params[:user_id])
            
            if @role.users.include?(user)
                flash[:success] = "Пользователь #{user.full_name} уже имеет эту роль"
            else
                @role.users << user
                redirect_to stored_referer
                flash[:success] = "Роль назначена пользователю #{user.full_name}"
            end
        else
            flash[:error] = "Нет доступа" 
        end
    end
    
    def remove_user
        if can?(:assign, @role)
                user = User.find(params[:user_id])
                user_role = UserRole.find_by(user: user, role: @role)
                if user_role
                    user_role.destroy
                    redirect_to stored_referer
                    flash[:success] = "Пользователю #{user.full_name} больше не назначена роль #{@role.name}"
                else
                    flash[:warning] = "Пользователь не имеет такую роль"
                end
        else
            flash[:error] = "Нет доступа" 
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