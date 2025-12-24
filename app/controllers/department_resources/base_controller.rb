module DepartmentResources
  class BaseController < ApplicationController
    before_action :set_department
    before_action :authenticate_user!
    
    private
    
    def set_department
      @department = Department.find(params[:department_id])
    end
    
    def current_department
      @department
    end
    helper_method :current_department
  end
end