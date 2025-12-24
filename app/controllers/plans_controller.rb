
class PlansController < ApplicationController
  before_action :authenticate_user!
  before_action :store_referer, only: [:bulk_add_events]
  before_action :set_plan, only: [:show, :edit, :update, :destroy, :events, :add_events, :add_event, :remove_event, :reorder, :bulk_add_events]
  before_action :check_permissions_for_plan, except: [:new, :create, :index, :department, :my_plans, :events]
  

  
  def show
  end 
  def create
    @plan = Plan.new(plan_params)
    @plan.creator = current_user
    check_permissions_for_plan
    if @plan.save
      redirect_to @plan, notice: 'План успешно создан'
    else
      render :new
    end
  end
  def update
    authorize_action(:edit, @plan)
    if @plan.update(plan_params)
      redirect_to @plan, notice: 'Подразделение успешно обновлено'
    else
      render :edit
    end
  end
  # app/controllers/plans_controller.rb
  def bulk_add_events
    event_department_ids = Array(params[:event_department_ids]).map(&:to_i)
    
    if event_department_ids.empty?
      redirect_back fallback_location: @plan, alert: "Не выбраны мероприятия для добавления"
      return
    end
    
    added_count = 0
    failed_count = 0
    
    event_department_ids.each do |event_department_id|
      event_department = ApprovedEventDepartment.find_by(id: event_department_id)
      next unless event_department
      
      # Проверяем что мероприятие из того же подразделения что и план
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
      redirect_to stored_referer alert: "Не удалось добавить мероприятия"
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
    authorize_action(:delete, @plan)
      @dept=@plan.department
      @plan.destroy
      redirect_to department_plans_path(@dept)
  end
  def available_for_events
    event_department_ids = params[:event_department_ids] || []
    min_start_date = params[:min_start_date]
    max_start_date = params[:max_start_date]
    
    # Проверяем что мероприятия существуют и принадлежат одному подразделению
    event_departments = ApprovedEventDepartment.where(id: event_department_ids)
    
    if event_departments.empty?
      return render json: { plans: [], error: "Мероприятия не найдены" }, status: :bad_request
    end
    
    # Проверяем что все мероприятия из одного подразделения
    department_ids = event_departments.pluck(:department_id).uniq
    if department_ids.count > 1
      return render json: { plans: [], error: "Мероприятия из разных подразделений" }, status: :bad_request
    end
    
    department = Department.find(department_ids.first)
    
    # Проверяем права доступа к планам этого подразделения
    unless can?(:add_event, department)
      return render json: { plans: [], error: "Нет доступа к планам этого подразделения" }, status: :forbidden
    end
    
    # Находим планы подразделения
    plans = Plan.for_department(department)
    
    # Фильтруем планы по периоду (если указаны даты)
    if min_start_date.present? && max_start_date.present?
      begin
        min_date = Date.parse(min_start_date)
        max_date = Date.parse(max_start_date)
        
        # Ищем планы, которые охватывают весь период мероприятий
        plans = plans.where('start_date <= ? AND end_date >= ?', min_date, max_date)
      rescue Date::Error
        # Если даты некорректные, пропускаем фильтрацию
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

  # Добавляем право view_plans в ABAC
  def can_view_plans?(department)
    can?(:add_event, department) 
  end
    private
    
    def set_plan
      @plan = Plan.find(params[:id])
    end
    def plan_params
      params.require(:plan).permit(:title, :description, :start_date, :end_date, :department_id)
    end
  end