module DepartmentResources
  class BaseController < ApplicationController
    before_action :set_department
    before_action :authenticate_user!
    before_action :store_referer

    private
    
    def set_department
      @department = Department.find(params[:department_id])
    end
  end
end