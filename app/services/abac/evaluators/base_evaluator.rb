module Abac
  module Evaluators
    class BaseEvaluator
      def evaluate?(user, resource, scope)
        raise NotImplementedError, "Each evaluator must implement evaluate?"
      end
      
      protected
      
      def same_department?(user, resource)
        resource.department == user.current_role.department
      end
      
      def child_department?(user, resource)
        resource.department.is_it_ancestor?(user.current_role.department)
      end
      
      def own_department_or_child?(user, resource)
        same_department?(user, resource) || child_department?(user, resource)
      end
    end
  end
end