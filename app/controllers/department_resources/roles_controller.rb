module DepartmentResources
    class RolesController < BaseController
        def index
            @roles = @department.roles.includes(:users)
            authorize_action(:show, @department)
        end
    end
end
