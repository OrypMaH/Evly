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
        if can?(:view,@event_departments.first) 
          @pagy, @event_departments = pagy(@event_departments, items: 20, page: @page)
        else
          @event_departments=[]
        end
        @events = []
        
      when 'offered'
        # Предложенные мероприятия (ожидают ответа)
        @event_departments = @department.offered_event_departments
                              .includes(event: [:direction, :level, :educational_organization])
                              .order(created_at: :desc)
        if can?(:view, @event_departments.first) 
          @pagy, @event_departments = pagy(@event_departments, items: 20, page: @page)
        else
          @event_departments=[]
        end
        @events = []
        
      when 'my_events'
        # Мои мероприятия (созданные пользователем)
        @events = current_user.events
                    .includes(:direction, :level, :educational_organization)
                    .order(created_at: :desc)
        if can?(:view, @events.first) 
          @pagy, @events = pagy(@events, items: 20, page: @page)
        else
          @events = []
        end
        @event_departments = []
        
      else
        @events = []
        @event_departments = []
      end
    end
  end
end