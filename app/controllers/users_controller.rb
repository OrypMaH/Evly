class UsersController < ApplicationController
    before_action :get_roles, only: [:edit_roles]
    
    before_action :authenticate_user!, only: [:manage_roles, :edit_roles, :update_roles, :update, :edit]
    def new
        @user = User.new
    end

    def create
        @user = User.new user_params
        if @user.save
            sign_in @user
            redirect_to root_path
            flash[:success] = "Здравствуйте, #{@user.surname} #{@user.name} #{@user.patronymic} Ваш ID: #{@user.id}, запомните и используйте его для входа"
        else
            render :new
        end
    end



    def edit_roles
        @user = User.find_by id: params[:id]
    end
    def update_roles
        @user = User.find_by id: params[:id]
        if @user.update(user_role_params)
            redirect_to edit_roles_user_path
        else
            redirect_to edit_roles_user_path
        end
    end
    def select_current_role
        @user = current_user # Только для себя
        role = Role.find_by(id: params[:role_id])
        
        if role && @user.roles.include?(role)
            @user.update(current_role: role)
            redirect_to request.referer || root_path, notice: "Текущая роль изменена на: #{role.name}"
        else
            redirect_to request.referer || root_path, alert: "Роль не найдена или не назначена вам"
        end
    end
    def update
        @user = User.find_by id: params[:id]
        if @user.update user_params
            redirect_to user_path
        else
            render :new
        end
    end
    def edit
        @user = User.find_by id: params[:id]
    end
    def user_params
        params.require(:user).permit(:surname, :name,:patronymic,:contact,:password, :password_confirmation)
    end
    def user_role_params
        params.require(:user).permit(role_ids:[])
    end
    
    def get_roles
        @roles = [] #future
    end
    

    def show
    # Пустой action чтобы избежать ошибки
        head :no_content
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
end