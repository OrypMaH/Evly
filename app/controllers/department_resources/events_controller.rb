# app/controllers/department_resources/events_controller.rb
module DepartmentResources
  class EventsController < BaseController
    def index
      @active_tab = params[:tab] || 'my_events'
      @department = Department.find(params[:department_id])
      @page = params[:page] || 1
      
      case @active_tab
      when 'approved'
        # Мероприятия, где подразделение уже участвует
        @event_departments = @department.approved_event_departments
                              .includes(event: [:direction, :level, :educational_organization])
                              .order(updated_at: :desc)
        @pagy, @event_departments = pagy(@event_departments, items: 20, page: @page)
        @events = []
        
      when 'offered'
        # Предложенные мероприятия (ожидают ответа)
        @event_departments = @department.offered_event_departments
                              .includes(event: [:direction, :level, :educational_organization])
                              .order(created_at: :desc)
        @pagy, @event_departments = pagy(@event_departments, items: 20, page: @page)
        @events = []
        
      when 'rejected'
        # Отклоненные мероприятия
        @event_departments = @department.rejected_event_departments
                              .includes(event: [:direction, :level, :educational_organization])
                              .order(updated_at: :desc)
        @pagy, @event_departments = pagy(@event_departments, items: 20, page: @page)
        @events = []
        
      when 'my_events'
        # Мои мероприятия (созданные пользователем)
        @events = current_user.events
                    .includes(:direction, :level, :educational_organization)
                    .order(created_at: :desc)
        @pagy, @events = pagy(@events, items: 20, page: @page)
        @event_departments = []
        
      else
        # Все мероприятия
        @events = Event.all
                    .includes(:direction, :level, :educational_organization)
                    .order(created_at: :desc)
        @pagy, @events = pagy(@events, items: 20, page: @page)
        @event_departments = []
      end
    end
  end
end