class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy, :role_list]
  before_action :authenticate_user!
  before_action :store_referer
  def index
    if current_user.current_role
      @departments = current_user.current_role.department.full_tree
    else
      @departments = []
    end
  end

  def show
    @parent = @department.parent
    
    @children = @department.children
    
    @participating_events = Event.participating_by(@department).limit(10)
    
    @roles = @department.roles.includes(:users)
    
    @total_users = @department.users.distinct.count
    @total_events = @participating_events.count
    authorize_action(:show, @department)
  end

  def new
    @department = Department.new(parent_id: params[:parent_id])
    authorize_action(:create, Department.find_by(id: params[:parent_id]))
  end

  def create
    @department = Department.new(department_params)
    if can?(:create, @department)
      if @department.save
        redirect_to @department, notice: 'Подразделение успешно создано'
      else
        redirect_to new_department_path(parent_id: @department.parent_id)
      end
    else
      redirect_to stored_referer, alert: "Недостаточно прав для создания подразделения"
    end
  end

  def edit
    authorize_action(:edit, @department)
  end

  def update
    if can?(:edit, @department)
      if @department.update(department_params.except(:parent_id))
        redirect_to @department, notice: 'Подразделение успешно обновлено'
      else
        render :edit
      end
    else
      redirect_to stored_referer, alert: "Недостаточно прав для редактирования этого подразделения"
    end
  end

  def destroy
    if can?(:delete, @department)
      if @department.children.any?
        redirect_to departments_path, alert: 'Невозможно удалить подразделение с дочерними элементами'
      elsif @department.roles.any?
        redirect_to departments_path, alert: 'Невозможно удалить подразделение с привязанными ролями'
      else
        @department.destroy
        redirect_to departments_path, notice: 'Подразделение успешно удалено'
      end
    else
      redirect_to stored_referer, alert: "Недостаточно прав для удаления этого подразделения"
    end 
  end


  
  def role_list
    @roles = @department.roles.includes(:users)
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :description, :parent_id)
  end
end