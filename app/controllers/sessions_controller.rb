class SessionsController < ApplicationController
    def new
        if (user_signed_in?)
            redirect_to root_path
            return
        end
    end

    def create
        if (user_signed_in?)
            redirect_to root_path
            return
        end
        user = User.find_by id: params[:id]
        if user&.authenticate(params[:password])
            sign_in user
            redirect_to root_path
        else
            redirect_to new_session_path
        end
    end

    def destroy
        session.delete :user_id
        redirect_to new_session_path
    end
end
