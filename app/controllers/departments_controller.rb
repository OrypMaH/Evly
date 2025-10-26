class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    if current_user.current_role
      @departments = current_department.tree
    else
      @departments = []
    end
  end

  def show
    @roles = @department.roles.includes(:users)
    authorize_action(:show, @department)
  end

  def new
    @department = Department.new(parent_id: params[:parent_id])
    authorize_action(:create, @department)
  end

  def create
    @department = Department.new(department_params)
    authorize_action(:create, @department)
    
    if @department.save
      redirect_to @department, notice: 'Подразделение успешно создано'
    else
      render :new
    end
  end

  def edit
    authorize_action(:edit, @department)
  end

  def update
    authorize_action(:edit, @department)
    if @department.update(department_params)
      redirect_to @department, notice: 'Подразделение успешно обновлено'
    else
      @available_parents = Department.where.not(id: @department.id)
      render :edit
    end
  end

  def destroy
    if @department.children.any?
      redirect_to departments_path, alert: 'Невозможно удалить подразделение с дочерними элементами'
    elsif @department.roles.any?
      redirect_to departments_path, alert: 'Невозможно удалить подразделение с привязанными ролями'
    else
      @department.destroy
      redirect_to departments_path, notice: 'Подразделение успешно удалено'
    end
  end

  def manage_roles
    if current_user.current_role
      @department = current_department
      
      @users = @department.users

      @user_department_roles = {}
      @users.each do |user|
        @user_department_roles[user.id] = user.roles.where(department: @department)
      end
    else
      @users = []
      @user_department_roles = {}
    end
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :description, :parent_id)
  end
end