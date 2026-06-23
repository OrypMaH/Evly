# app/controllers/plans/plan_events_controller.rb
  class PlanEventsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_plan , except: [:destroy]
    before_action :set_plan_event, only: [:destroy]
    before_action :store_referer, only:[:destroy]
    
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
      event_title = @plan_event.event_department.event.title
      if can?(:delete, @plan_event)
        if @plan_event.destroy
          redirect_to stored_referer, notice: "Мероприятие '#{event_title}' удалено из плана"
        else
          redirect_to stored_referer, alert: "Не удалось удалить мероприятие из плана"
        end
      else
        
      end
    end

    def bulk_create
      event_department_ids = Array(params[:event_department_ids]).map(&:to_i)
      
      if event_department_ids.empty?
        return render json: { error: "Не выбраны мероприятия" }, status: :bad_request
      end
      
      added_count = 0
      errors = []
      
      event_department_ids.each do |event_department_id|
        event_department = ApprovedEventDepartment.find_by(id: event_department_id)
        
        unless event_department
          errors << "Мероприятие #{event_department_id} не найдено"
          next
        end
        
        plan_event = @plan.plan_events.build(event_department: event_department)
        begin
          
          unless can?(:create, plan_event)
            errors << "Нет прав на добавление этого мероприятия"
            next
          end
          # Проверка принадлежности к одной кафедре
          if event_department.department != @plan.department
            errors << "Мероприятие из другого подразделения"
            next
          end
          
          # Проверка дублирования
          if @plan.plan_events.exists?(event_department_id: event_department_id)
            errors << "Мероприятие уже в плане"
            next
          end
          
          # Создание связи
          plan_event.save!
          added_count += 1
        end
      end
      if added_count > 0
        render json: { 
          success: true, 
          added_count: added_count,
          errors: errors
        }
      else
        render json: { 
          success: false, 
          errors: errors 
        }, status: :unprocessable_entity
      end
    end
  

    private


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
    
    def set_plan
      @plan = Plan.find(params[:plan_id])
    end
    
    def set_plan_event
      @plan_event = PlanEvent.find(params[:id])
      @plan = @plan_event.plan
    end
  end