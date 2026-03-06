module DepartmentResources
    class PlansController < BaseController
        before_action :set_plan, only: [:show, :edit, :update ]
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
        def show

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
        def create
            @plan = Plan.new(plan_params)
            @plan.creator = current_user
            check_permissions_for_plan
            if @plan.save
                redirect_to [@plan.department, @plan], notice: 'План успешно создан'
            else
                render :new
            end
        end
        def update
            authorize_action(:edit, @plan)
            if @plan.update(plan_params)
                redirect_to [@department,@plan], notice: 'Подразделение успешно обновлено'
            else
                render :edit
            end
        end
        private
        def set_plan
            @plan = Plan.find(params[:id])
        end
        def plan_params
            params.require(:plan).permit(:title, :description, :start_date, :end_date, :department_id)
        end
    end
end
