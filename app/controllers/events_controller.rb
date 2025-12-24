class EventsController < ApplicationController
 
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :store_referer, only: [:new, :edit, :destroy, :update, :show, :offer]

  
  def destroy
  # Сначала проверяем права, потом ищем мероприятие 
      if abac_engine.can?(:delete, @event)
          @event.destroy
          redirect_to stored_referer, notice: "Мероприятие удалено"
      else
          redirect_to stored_referer, alert: "Недостаточно прав для удаления этого мероприятия"
      end
  end

  def edit
      authorize_action(:edit, @event)
  end

  def update
      if abac_engine.can?(:update, @event)
        if @event.update event_params
          redirect_to stored_referer, notice: "Мероприятие обновлено"
        else
          redirect_to stored_referer, alert: "Что-то пошло не так"
        end
        
      else
          redirect_to stored_referer, alert: "Недостаточно прав для редактирования этого мероприятия"
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
          redirect_to stored_referer || department_events_path(current_user.department)
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
      redirect_to stored_referer, notice: success_message
    else
      error_message = authorized_offers[:errors].join(', ') || "Не удалось создать предложения участия"
      redirect_to stored_referer, alert: error_message
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
      params.require(:event).permit(:title,:description, :start_date, :end_date)
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
  def set_department
    @department = Department.find(params[:department_id])
  end
end