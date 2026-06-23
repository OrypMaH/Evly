
module Abac
  module Evaluators
    class DepartmentScopedEvaluator < BaseEvaluator
      def evaluate?(user, resource, scope)
        case scope
        when "own_department"
          same_department?(user, resource)
        when "child_departments"
          child_department?(user, resource)
        else
          false
        end
      end
    end
  end
end