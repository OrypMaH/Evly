# app/services/abac/evaluators/plan_event_evaluator.rb
module Abac
  module Evaluators
    class UserEvaluator < BaseEvaluator
      def evaluate?(user, resource, action)
        case action
        when :edit
          user.id==resource.id||user.current_role.is_admin?
        else
          false
        end
      end
    end
  end
end