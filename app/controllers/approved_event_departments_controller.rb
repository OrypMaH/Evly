class ApprovedEventDepartmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :store_referer, only: [:approve, :reject]
  def approve
    @approved = ApprovedEventDepartment.find(params[:id])
    
    if can?(:approve, @approved)
      participants_count = params[:participants_count] || 1
      
      @approved.approve!(current_user, participants_count)
      redirect_to stored_referer, notice: "Участие в мероприятии #{@event_department.event.title} изменено"
    else
      redirect_to stored_referer, alert: "Недостаточно прав для утверждения участия"
    end
  end

  def reject
    @approved = ApprovedEventDepartment.find(params[:id])
    if can?(:reject, @approved)
      title = @approved.event.title
      @approved.reject!
      redirect_to stored_referer, notice: "Участие в мероприятии #{title} отклонено"
    else
      redirect_to stored_referer, alert: "Недостаточно прав для отклонения участия"
    end
  end
end