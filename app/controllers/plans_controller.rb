
class PlansController < ApplicationController
  before_action :authenticate_user!
  before_action :store_referer, only: [:bulk_add_events]
  before_action :set_plan, only: [:export_excel, :destroy,:events, :add_events, :add_event, :remove_event, :reorder, :bulk_add_events]
  
  def index
      if params[:for_bulk_add].present?
        render_bulk_add_plans
      else
        @plans = []
      end
  end
  
  def bulk_add_events
    event_department_ids = Array(params[:event_department_ids]).map(&:to_i)
    unless can?(:add_event, @plan.department)
      redirect_back fallback_location: @plan, alert: "Нет прав на добавление мероприятий в планы подразделение @plan.department.name"
      return
    end
    if event_department_ids.empty?
      redirect_back fallback_location: @plan, alert: "Не выбраны мероприятия для добавления"
      return
    end
    
    added_count = 0
    failed_count = 0
    
    event_department_ids.each do |event_department_id|
      event_department = ApprovedEventDepartment.find_by(id: event_department_id)
      next unless event_department
      
      if event_department.department == @plan.department
        unless @plan.event_department_ids.include?(event_department_id)
          if @plan.plan_events.create(event_department: event_department)
            added_count += 1
          else
            failed_count += 1
          end
        end
      else
        failed_count += 1
      end
    end
    
    if added_count > 0
      message = "Добавлено #{added_count} мероприятий в план"
      message += " (не удалось добавить #{failed_count})" if failed_count > 0
      redirect_to stored_referer, notice: message
    else
      redirect_to stored_referer, alert: "Не удалось добавить мероприятия"
    end
  end
  
  def department_plans
    department = Department.find(params[:department_id])
    @plans = Plan.for_department(department).order(created_at: :desc)
    
    render json: { 
      plans: @plans.map { |plan| 
        { 
          id: plan.id, 
          title: plan.title,
          period: "#{plan.start_date.strftime('%d.%m.%Y')} - #{plan.end_date.strftime('%d.%m.%Y')}",
          events_count: plan.plan_events.count
        } 
      } 
    }
  end

  def destroy
      dept=@plan.department
      @plan.destroy
      redirect_to department_plans_path(dept)
  end
  def render_bulk_add_plans
    
    event_department_ids = Array(params[:event_department_ids]).map(&:to_i)
    min_start_date = params[:min_start_date]
    max_start_date = params[:max_start_date]
    
    event_departments = ApprovedEventDepartment.where(id: event_department_ids)
    
    department_ids = event_departments.pluck(:department_id).uniq
    if department_ids.count > 1
      return render json: { plans: [], error: "Мероприятия из разных подразделений" }, status: :bad_request
    end
    
    department = Department.find(department_ids.first)
    
    unless can?(:add_event, department)
      return render json: { plans: [], error: "Нет доступа к планам этого подразделения" }, status: :forbidden
    end
    
    plans = department.plans
    
    if min_start_date.present? && max_start_date.present?
      begin
        min_date = Date.parse(min_start_date)
        max_date = Date.parse(max_start_date)
        
        plans = plans.where('start_date <= ? AND end_date >= ?', min_date, max_date)
      rescue Date::Error
      end
    end
    
    # Добавляем количество мероприятий в каждом плане
    plans_with_counts = plans.map do |plan|
      {
        id: plan.id,
        title: plan.title,
        start_date: plan.start_date.strftime('%d.%m.%Y'),
        end_date: plan.end_date.strftime('%d.%m.%Y'),
        events_count: plan.plan_events.count,
        department_id: plan.department_id
      }
    end
    
    render json: { plans: plans_with_counts }
  end
  def export_excel
    if can?(:show, @plan)
      exporter = PlanExporter.new(@plan)
      package = exporter.generate
      
      respond_to do |format|
        format.xlsx do
          send_data package.to_stream.read,
                    filename: "plan_#{@plan.id}_#{Date.today}.xlsx",
                    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    disposition: 'attachment'
        end
      end
    else
      redirect_to stored_referer || department_path(current_department)
      flash[:error] = "Нет доступа" 
    end
  end
  private
  def set_plan
      @plan = Plan.find(params[:id])
  end
end