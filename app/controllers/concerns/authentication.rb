module Authentication
    extend ActiveSupport::Concern
    included do
        private
        def current_user
            @current_user ||=User.find_by(id: session[:user_id]) if session[:user_id].present?
        end

        def current_department
            @current_department = @current_user.department
        end

        def user_signed_in?
            current_user.present?
        end

        def sign_in(user)
            session[:user_id] = user.id
        end
        
        def authenticate_user!
            unless user_signed_in?
                redirect_to new_session_path
            end
        end

        helper_method :current_user, :current_department, :user_signed_in?, :authenticate_user!
    end

end
