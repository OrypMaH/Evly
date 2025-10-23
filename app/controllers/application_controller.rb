class ApplicationController < ActionController::Base
    include Authentication
    include Authorization
    include Referencing
end
