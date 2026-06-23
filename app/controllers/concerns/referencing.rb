module Referencing
    extend ActiveSupport::Concern
    included do
        private
        def store_referer
            session[:referer] = request.referer
        end
        
        def stored_referer
            session.delete(:referer)
        end
        helper_method :store_referer, :stored_referer
    end
end