module Authorization
    extend ActiveSupport::Concern
    included do
        private
        def authorize_action(action, resource)
            unless AbacEngine.new(current_user).can?(action, resource)
            redirect_to root_path, alert: "Доступ запрещен"
            end
            if resource == Role.name && (action == :edit||action== :create)
                resource.permissions.keep_if{|perm| current_user.current_role.permissions.include?(perm)}
            end
        end
        helper_method :authorize_action
    end
end