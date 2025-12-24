class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy, :role_list]
  before_action :authenticate_user!

  def index
    if current_user.current_role
      @departments = current_department.tree
    else
      @departments = []
    end
  end

  def show
     # Ближайший предок (родитель)
    @parent = @department.parent
    
    # Ближайшие дочерние подразделения (первого уровня)
    @children = @department.children
    
    # Все мероприятия где подразделение участвует (утвержденные)
    @participating_events = Event.participating_by(@department).limit(10)
    
    # Роли в этом подразделении
    @roles = @department.roles.includes(:users)
    
    # Статистика
    @total_users = @department.users.distinct.count
    @total_events = @participating_events.count
  end

  def new
    @department = Department.new(parent_id: params[:parent_id])
    authorize_action(:create, Department.find_by(id: params[:parent_id]))
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
    authorize_action(:delete, @department)
    if @department.children.any?
      redirect_to departments_path, alert: 'Невозможно удалить подразделение с дочерними элементами'
    elsif @department.roles.any?
      redirect_to departments_path, alert: 'Невозможно удалить подразделение с привязанными ролями'
    else
      @department.destroy
      redirect_to departments_path, notice: 'Подразделение успешно удалено'
    end
  end


  
  def role_list
    @roles = @department.roles.includes(:users)
    authorize_action(:show, @department)
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :description, :parent_id)
  end
end