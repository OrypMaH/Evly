module DepartmentResources
    class EventsController < BaseController
        def index
            @active_tab = params[:tab] || 'my_events'
            case @active_tab
            when 'approved'
                # Мероприятия, где подразделение уже участвует
                @events = []
                @event_departments = @department.approved_event_departments
            when 'offered'
                # Предложенные мероприятия (ожидают ответа)
                @events = []
                @event_departments = @department.offered_event_departments
            when 'rejected'
                # Отклоненные мероприятия
                @events = []
                @event_departments = @department.rejected_event_departments
            when 'my_events'
                # Мои мероприятия (созданные пользователем)
                @events = current_user.events
                @event_departments = []
            else
                # Все мероприятия
                @events = []
                @event_departments[]
            end
        end
    end
end
