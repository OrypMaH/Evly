class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!

    def index
        @active_tab = params[:tab] || 'participating'

        case @active_tab
        when 'approved'
            # Мероприятия, где подразделение уже участвует
            @events = Event.participating_by(current_department)
        when 'offered'
            # Предложенные мероприятия (ожидают ответа)
            @events = Event.offered_to(current_department)
        when 'rejected'
            # Отклоненные мероприятия
            @events = Event.rejected_by(current_department)
        when 'my_events'
            # Мои мероприятия (созданные пользователем)
            @events = current_user.events
        else
            # Все мероприятия
            @events = []
        end
    end
    
    def destroy
    # Сначала проверяем права, потом ищем мероприятие
        authorize_action(:delete, Event)  
        if abac_engine.can?(:delete, @event)
            @event.destroy
            redirect_to events_path, notice: "Мероприятие удалено"
        else
            redirect_to events_path, alert: "Недостаточно прав для удаления этого мероприятия"
        end
    end

    def edit
        authorize_action(:edit, @event)
    end

    def update
        authorize_action(:edit, @event)
        if @event.update event_params
            redirect_to events_path
        else
            render :new
        end
    end

    def new
        @event = Event.new()
        authorize_action(:create, @event)
    end

    def create
        @event=Event.new event_params
        @event.creator=current_user
        authorize_action(:create, @event)
        if @event.save
            redirect_to events_path
        else 
            render :new
        end
    end

def offer
  @event = Event.find(params[:id])
  
  if request.post?
    handle_post_request
  else
    # Для GET запроса просто показываем страницу
    @available_departments = find_available_departments_for_action('offer')
  end
end

def available_departments
  @event = Event.find(params[:id])
  @available_departments = find_available_departments_for_action('offer')
  
  render json: { 
    departments: @available_departments.map { |dept| 
      { id: dept.id, name: dept.name, description: dept.description } 
    }
  }
end

private

def handle_post_request
  selected_department_ids = Array(params[:department_ids]).map(&:to_i)
  
  if selected_department_ids.empty?
    redirect_to offer_event_path(@event), alert: "Выберите хотя бы одно подразделение"
    return
  end
  
  # Фильтруем только те подразделения, к которым есть права
  authorized_offers = create_authorized_offers(selected_department_ids)
  
  if authorized_offers[:successful].any?
    success_message = "Участие предложено подразделениям: #{authorized_offers[:successful].map(&:name).join(', ')}"
    redirect_to events_path, notice: success_message
  else
    error_message = authorized_offers[:errors].join(', ') || "Не удалось создать предложения участия"
    redirect_to offer_event_path(@event), alert: error_message
  end
end

def create_authorized_offers(selected_department_ids)
  successful = []
  errors = []
  
  selected_department_ids.each do |department_id|
    department = Department.find_by(id: department_id)
    
    unless department
      errors << "Подразделение ##{department_id} не найдено"
      next
    end
    
    unless can_offer_to_department?(@event, department)
      errors << "Нет прав предлагать участие подразделению #{department.name}"
      next
    end
    
    # Проверяем, не предложено ли уже участие
    if OfferedEventDepartment.exists?(event: @event, department: department)
      errors << "Участие уже предложено подразделению #{department.name}"
      next
    end
    
    event_department = OfferedEventDepartment.create(
      event: @event,
      department: department,
      proposed_by: current_user
    )
    
    if event_department.persisted?
      successful << department
    else
      errors << "Ошибка создания предложения для #{department.name}: #{event_department.errors.full_messages.join(', ')}"
    end
  end
  
  { successful: successful, errors: errors }
end

def can_offer_to_department?(event, department)
  temp_ed = OfferedEventDepartment.new(event: event, department: department)
  can?(:offer, temp_ed)
end
def can_offer_to_department?(event, department)
  temp_ed = OfferedEventDepartment.new(event: event, department: department)
  can?(:offer, temp_ed)
end
    def set_event
        @event = Event.find(params[:id])
    end

    def event_params
        params.require(:event).permit(:title,:description)
    end

    def can_offer_to_department?(event, department)
        # Проверяем через основной метод доступных подразделений
        available_departments = find_available_departments_for_action('offer')
        available_departments.include?(department)
    end
    
    def can_assign_to_department?(event, department)
        # Проверяем через основной метод доступных подразделений
        available_departments = find_available_departments_for_action('assign')
        available_departments.include?(department)
    end

    def find_available_departments_for_action(act)
    available_departments = Set.new
    current_user.roles.each do |role|
        # Проверяем права offer для этой роли
        role.permissions.where(action: act, resource: 'EventDepartment').each do |permission|
            case permission.scope
            when 'own_department' # Добавляем только подразделение роли
                available_departments.add(role.department) if role.department
            when 'department_hierarchy' # Добавляем всю иерархию: родители + текущее + дети
                if role.department
                    hierarchy_departments = [role.department] + role.department.ancestors + role.department.descendants
                    hierarchy_departments.each do |dept|
                        available_departments.add(dept)
                    end
                end
            end
        end
    end
    
    # ВОЗВРАЩАЕМ результат и убираем подразделения, которые уже участвуют
    available_departments.to_a.reject { |dept| @event.departments.include?(dept) }
    end
end