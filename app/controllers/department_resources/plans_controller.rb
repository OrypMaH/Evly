module DepartmentResources
    class PlansController < BaseController
        def index
            @plans = @department.plans.order(start_date: :desc)
            
            # Разделение планов по статусам
            @active_plans = @plans.active
            @upcoming_plans = @plans.where('start_date > ?', Date.current)
            @past_plans = @plans.where('end_date < ?', Date.current)
            
            # Фильтр по периоду
            @period_filter = params[:period] || 'all'
            
            case @period_filter
            when 'active'
                @plans = @active_plans
            when 'upcoming'
                @plans = @upcoming_plans
            when 'past'
                @plans = @past_plans
            end
        end
        
        def new
            @plan = Plan.new(
                department: @department,
                creator: current_user,
                start_date: Date.current,
                end_date: Date.current + 1.month
            )
            check_permissions_for_plan
        end
    end
end
