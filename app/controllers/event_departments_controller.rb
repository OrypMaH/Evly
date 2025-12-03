class EventDepartmentsController < ApplicationController
  def approve
    @event_department = EventDepartment.find(params[:id])
    
    if can?(:approve, @event_department)
      if @event_department.update(
        status: :approved,
        approved_at: Time.current,
        participants_count: params[:participants_count] || 1
      )
        render json: { 
          success: true, 
          message: "Участие утверждено успешно" 
        }
      else
        render json: { 
          success: false, 
          message: @event_department.errors.full_messages.join(', ') 
        }
      end
    else
      render json: { 
        success: false, 
        message: "Недостаточно прав для утверждения участия" 
      }
    end
  end
end