class SessionsController < ApplicationController
    def new
        
    end

    def create
        user = User.find_by id: params[:id]
        if user&.authenticate(params[:password])
            sign_in user
            redirect_to root_path
        else
            flash[:warning] = "Неа"
            redirect_to new_session_path
        end
    end

    def destroy
        session.delete :user_id
        redirect_to new_session_path
    end
end
