class OfferedEventDepartmentsController < ApplicationController
  before_action :store_referer, only: [:approve, :reject]
  def approve
    @offered = OfferedEventDepartment.find(params[:id])
    
    if can?(:approve, @offered)
      participants_count = params[:participants_count]
      @offered.approve!(current_user, participants_count)
      
      redirect_to stored_referer, notice: "Участие в мероприятии утверждено"
    else
      redirect_to stored_referer, alert: "Недостаточно прав для утверждения участия"
    end
  end
  

  def reject
    @offered = OfferedEventDepartment.find(params[:id])
    if can?(:reject, @offered)
      title = @offered.event.title
      @offered.reject!
      
      redirect_to stored_referer, notice: "Участие в мероприятии #{title} отклонено"
    else
      redirect_to stored_referer, alert: "Недостаточно прав для отклонения участия"
    end
  end
end