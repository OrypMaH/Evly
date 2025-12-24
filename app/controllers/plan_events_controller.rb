# app/controllers/plans/plan_events_controller.rb
module Plans
  class PlanEventsController < ApplicationController
    before_action :set_plan
    before_action :set_plan_event, only: [:destroy]
    before_action :check_permissions
    
    def create
      event_department = ApprovedEventDepartment.find(params[:event_department_id])
      
      # Проверяем, что мероприятие принадлежит подразделению плана
      if event_department.department != @plan.department
        redirect_back fallback_location: plan_path(@plan),
                      alert: "Мероприятие не принадлежит подразделению плана"
        return
      end
      
      @plan_event = @plan.plan_events.new(event_department: event_department)
      
      if @plan_event.save
        redirect_back fallback_location: plan_path(@plan),
                      notice: "Мероприятие добавлено в план"
      else
        redirect_back fallback_location: plan_path(@plan),
                      alert: "Ошибка: #{@plan_event.errors.full_messages.join(', ')}"
      end
    end
    
    def destroy
      @plan_event.destroy
      redirect_back fallback_location: plan_path(@plan),
                    notice: "Мероприятие удалено из плана"
    end
    
    # app/controllers/plans_controller.rb
    def available_plans_for_events
      # Получаем список ID предложенных мероприятий
      offered_event_department_ids = Array(params[:offered_event_department_ids]).map(&:to_i)
      
      if offered_event_department_ids.empty?
        return render json: { error: "Не переданы ID мероприятий" }, status: :bad_request
      end
      
      # Находим все предложенные мероприятия
      offered_events = OfferedEventDepartment.includes(:event, :department)
                                            .where(id: offered_event_department_ids)
      
      if offered_events.empty?
        return render json: { error: "Мероприятия не найдены" }, status: :not_found
      end
      
      # Проверяем что все мероприятия из одного подразделения
      departments = offered_events.map(&:department).uniq
      if departments.count > 1
        return render json: { 
          error: "Мероприятия принадлежат разным подразделениям",
          departments: departments.map(&:name) 
        }, status: :bad_request
      end
      
      target_department = departments.first
      
      # Проверяем права пользователя на это подразделение
      unless can_access_department_plans?(current_user, target_department)
        return render json: { 
          error: "Нет доступа к планам подразделения #{target_department.name}" 
        }, status: :forbidden
      end
      
      # Рассчитываем охватывающий период (по датам начала мероприятий)
      event_dates = offered_events.map { |oe| oe.event.start_date }
      min_date = event_dates.min
      max_date = event_dates.max
      
      # Находим планы подразделения, охватывающие этот период
      # План считается охватывающим период, если его start_date <= min_date и end_date >= max_date
      available_plans = Plan.for_department(target_department)
                            .where('start_date <= ? AND end_date >= ?', min_date, max_date)
                            .order(created_at: :desc)
      
      # Также можно показать планы, которые хотя бы частично пересекаются с периодом
      overlapping_plans = Plan.for_department(target_department)
                              .where('start_date <= ? AND end_date >= ?', max_date, min_date)
                              .where.not(id: available_plans.select(:id))
                              .order(created_at: :desc)
      
      render json: {
        department: {
          id: target_department.id,
          name: target_department.name
        },
        period: {
          min_date: min_date.strftime('%d.%m.%Y'),
          max_date: max_date.strftime('%d.%m.%Y'),
          days: (max_date.to_date - min_date.to_date).to_i
        },
        plans: available_plans.map { |plan| format_plan_for_json(plan, :full_coverage) },
        overlapping_plans: overlapping_plans.map { |plan| format_plan_for_json(plan, :partial_coverage) },
        selected_events_count: offered_events.count
      }
    end

    private

    def can_access_department_plans?(user, department)
      # Проверяем права на просмотр планов подразделения
      # 1. Пользователь должен иметь роль в этом подразделении ИЛИ
      # 2. Иметь право на управление планами дочерних подразделений
      
      # Проверка по ролям пользователя
      user_has_access = user.departments.include?(department)
      
      # ИЛИ проверка прав ABAC
      abac_access = can?(:view, Plan.new(department: department))
      
      user_has_access || abac_access
    end

    def format_plan_for_json(plan, coverage_type = :full_coverage)
      {
        id: plan.id,
        title: plan.title,
        description: plan.description,
        start_date: plan.start_date.strftime('%d.%m.%Y'),
        end_date: plan.end_date.strftime('%d.%m.%Y'),
        coverage_type: coverage_type.to_s,
        events_count: plan.plan_events.count,
        can_add_events: can?(:add_event, plan.department),
        period_text: "#{plan.start_date.strftime('%d.%m.%Y')} - #{plan.end_date.strftime('%d.%m.%Y')}",
        coverage_badge: coverage_badge(coverage_type)
      }
    end

    def coverage_badge(coverage_type)
      case coverage_type
      when :full_coverage
        { text: "Полное покрытие", class: "green", icon: "check circle" }
      when :partial_coverage
        { text: "Частичное покрытие", class: "yellow", icon: "warning circle" }
      else
        { text: "Неизвестно", class: "grey", icon: "question circle" }
      end
    end
    
    def set_plan
      @plan = Plan.find(params[:plan_id])
    end
    
    def set_plan_event
      @plan_event = @plan.plan_events.find(params[:id])
    end
    
    def check_permissions
      case action_name.to_sym
      when :create
        authorize_action(:add_event, @plan)
      when :destroy
        authorize_action(:remove_event, @plan)
      end
    end
  end
end