# app/services/abac/evaluators/plan_event_evaluator.rb
module Abac
  module Evaluators
    class PlanEventEvaluator < BaseEvaluator
      def evaluate?(user, resource, scope)
        case scope
        when "own_department"
          resource.event_department.department == user.current_role.department &&
          resource.plan.department == user.current_role.department
        else
          false
        end
      end
    end
  end
end