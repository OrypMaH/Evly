module Abac
  module Evaluators
    class EventDepartmentEvaluator < BaseEvaluator
      def evaluate?(user, resource, scope)
        case scope
        when "own_department"
          same_department?(user, resource)
        when "department_hierarchy"
          
          same_department?(user, resource) || child_department?(user, resource)
        else
          false
        end
      end
    end
  end
end