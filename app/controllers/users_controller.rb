class UsersController < ApplicationController
    include CurrentDepartmentRedirect
    before_action :store_referer, only: [:select_current_role]
    
    before_action :authenticate_user!, except: [:new, :create]
    def new
        if (user_signed_in?)
            redirect_to root_path
            return
        end
        @user = User.new
    end

    def create
        if (user_signed_in?)
            redirect_to root_path
            return
        end
        @user = User.new user_params
        if @user.save
            sign_in @user
            redirect_to root_path
            flash[:success] = "Здравствуйте, #{@user.surname} #{@user.name} #{@user.patronymic} Ваш ID: #{@user.id}, запомните и используйте его для входа"
        else
            render :new
        end
    end

    def roles
        user = User.find(params[:id])
        
        roles = user.roles
        
        render json: roles.map { |role| 
            {
                id: role.id,
                name: role.name
            }
        }
        rescue ActiveRecord::RecordNotFound
            render json: { error: 'User not found' }, status: :not_found
    end

    def select_current_role
        @user = current_user
        role = Role.find_by(id: params[:role_id])
        
        if role && @user.roles.include?(role)
            @user.update(current_role: role)
            
            redirect_to redirect_with_proper_department,
                        notice: "Текущая роль изменена на: #{role.name}"
        else
            redirect_back fallback_location: root_path,
                        alert: "Роль не найдена или не назначена вам"
        end
    end

    def update
        @user = User.find(params[:id])
        if current_user != @user && !current_user.current_role.is_admin?
                redirect_to edit_user_path(current_user)
        end
        if  @user.update(user_params)
            redirect_to user_path(@user)
        else
            redirect_to edit_user_path(@user)
        end
    end
    
    def edit
        @user = User.find(params[:id])
        if current_user != @user && !current_user.current_role.is_admin?
                redirect_to edit_user_path(current_user)
        end
    end
    
    def show
        @user = User.find(params[:id])
    end
    
    def search
        puts "=== SEARCH DEBUG ==="
        puts "Query: #{params[:q]}"
        puts "Params: #{params.inspect}"
        
        if params[:q].present?
            users = User.where("surname ILIKE :q OR name ILIKE :q", q: "%#{params[:q]}%").limit(10)
            puts "Found users: #{users.count}"
            users.each { |u| puts "- #{u.full_name}" }
            
            result = { 
            users: users.map { |u| { id: u.id, full_name: u.full_name } } 
            }
            puts "JSON response: #{result.to_json}"
            
            render json: result
        else
            puts "Empty query"
            render json: { users: [] }
        end
    end
    private
    def user_params
        params.require(:user).permit(:surname, :name,:patronymic,:contact,:password, :password_confirmation)
    end
    def user_role_params
        params.require(:user).permit(role_ids:[])
    end
end