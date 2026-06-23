module Authorization
    extend ActiveSupport::Concern
    included do
        private
        def authorize_action(action, resource)
            unless can?(action, resource)
                redirect_to request.referer || root_path, alert: "Доступ запрещен"
            end
            if resource == Role.name && (action == :edit||action== :create)
                resource.permissions.keep_if{|perm| current_user.current_role.permissions.include?(perm)}
            end
        end

        def abac_engine
            @abac_engine ||= Abac::AbacEngine.new(current_user)
        end

        def can?(action, resource)
            abac_engine.can?(action, resource)
        end
        helper_method :authorize_action, :can?
    end
end