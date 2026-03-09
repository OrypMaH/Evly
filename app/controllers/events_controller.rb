class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy,:available_departments, :add_responsible_person]
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
      @directions = current_user.direction_list
  end
  def show
  end# app/controllers/events_controller.rb
def update
  if abac_engine.can?(:update, @event)
    # Обновляем основные атрибуты мероприятия
    if @event.update(event_params)
      redirect_to stored_referer, notice: "Мероприятие обновлено"
    else
      redirect_to stored_referer, alert: "Что-то пошло не так: #{@event.errors.full_messages.join(', ')}"
    end
    
  else
    redirect_to stored_referer, alert: "Недостаточно прав для редактирования этого мероприятия"
  end
end

  def new
      @event = Event.new(educational_organization: EducationalOrganization.first())
      @directions = current_user.direction_list
      authorize_action(:create, @event)
  end

  def create
      @event = Event.new(event_params.except(:responsible_people_attributes))
      @event.creator=current_user
      authorize_action(:create, @event)
      if params[:event][:responsible_people_attributes].present?
        params[:event][:responsible_people_attributes].each do |_, rp_params|
          next if rp_params[:_destroy] == '1'
          
          @event.responsible_people.build(
            user_id: rp_params[:user_id],
            role_id: rp_params[:role_id]
          )
        end
      end
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
  #???
  def can_offer_to_department?(event, department)
    temp_ed = OfferedEventDepartment.new(event: event, department: department)
    can?(:offer, temp_ed)
  end
  def set_event
      @event = Event.find(params[:id])
  end

  def event_params
      params.require(:event).permit(
        :title, 
        :description, 
        :start_date, 
        :end_date, 
        :format, 
        :location, 
        :event_level_id, 
        :direction_id, 
        :educational_organization_id,
        responsible_people_attributes: [
          :id, :user_id, :role_id, :_destroy
        ]
      )
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

  def responsible_person_json(rp)
    {
      id: rp.id,
      user_id: rp.user_id,
      user_name: rp.user.full_name,
      role_id: rp.role_id,
      role_name: rp.role.name,
      created_at: rp.created_at
    }
  end
end