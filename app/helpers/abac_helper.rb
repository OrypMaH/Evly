module AbacHelper
    def abac_engine
        @abac_engine ||= AbacEngine.new(current_user)
    end
    def can?(action, resource = nil)
        abac_engine.can?(action, resource)
    end
end
