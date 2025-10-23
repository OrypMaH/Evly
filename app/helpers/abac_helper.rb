module AbacHelper
    def abac_engine
        @abac_engine ||= AbacEngine.new(current_user)
    end
end
