module AbacHelper
    def can?(action, resource = nil)
        abac_engine.can?(action, resource)
    end
    private
    def abac_engine
        @abac_engine ||= Abac::AbacEngine.new(current_user)
    end
end
