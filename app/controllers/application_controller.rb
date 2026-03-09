class ApplicationController < ActionController::Base
    include Authentication
    include Authorization
    include Referencing
    include PermissionsInheritanceHandler
    include Pagy::Backend
end
