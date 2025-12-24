module DepartmentRedirectable
  extend ActiveSupport::Concern
  
  included do
    before_action :set_department, if: -> { params[:department_id].present? }
  end
  
  def redirect_to_department_events(options = {})
    redirect_to department_events_path(@department), options
  end
  
  def redirect_to_department_plans(options = {})
    redirect_to department_plans_path(@department), options
  end
  
  private
  
  def set_department
    @department = Department.find(params[:department_id])
  end
end