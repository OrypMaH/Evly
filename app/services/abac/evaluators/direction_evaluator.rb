# app/services/abac/evaluators/direction_evaluator.rb
module Abac
  module Evaluators
    class DirectionEvaluator < BaseEvaluator
      def evaluate?(user, resource, scope)
        case scope
        when "own_department"
          resource.department == user.current_role.department
        else
          true
        end
      end
    end
  end
end