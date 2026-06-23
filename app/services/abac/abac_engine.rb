# app/services/abac/engine.rb
module Abac
  class AbacEngine
    attr_reader :user
    
    def initialize(user)
      @user = user
    end
    
    def can?(action, resource)
      return false unless user.current_role
      if resource.class.name=='User'
        evaluator = evaluator_for(resource)
        evaluator.evaluate?(user, resource, action)
      else
        # Находим подходящие разрешения
        relevant_permissions = user.current_role.permissions.select do |permission|
          resource_class_matches?(permission, resource) && 
          permission.action == action.to_s
        end 
        # Проверяем каждое разрешение через соответствующий evaluator
        relevant_permissions.any? do |permission|
          evaluator = evaluator_for(resource)
          evaluator.evaluate?(user, resource, permission.scope)
        end
      end
      
     
    end
    
    private
    
    def resource_class_matches?(permission, resource)
      case permission.resource
      when 'EventDepartment'
        ['OfferedEventDepartment', 'ApprovedEventDepartment'].include?(resource.class.name)
      else
        permission.resource == resource.class.name
      end
    end
    
    def evaluator_for(resource)
      resource_type = resource.class.name
      
      evaluators = {
        'Event' => Abac::Evaluators::EventEvaluator,
        'OfferedEventDepartment' => Abac::Evaluators::EventDepartmentEvaluator,
        'ApprovedEventDepartment' => Abac::Evaluators::EventDepartmentEvaluator,
        'Role' => Abac::Evaluators::DepartmentScopedEvaluator,
        'Department' => Abac::Evaluators::DepartmentScopedEvaluator,
        'Plan' => Abac::Evaluators::DepartmentScopedEvaluator,
        'PlanEvent' => Abac::Evaluators::PlanEventEvaluator,
        'Direction' => Abac::Evaluators::DirectionEvaluator,
        'User' => Abac::Evaluators::UserEvaluator
      }
      
      evaluator_class = evaluators[resource_type] || Abac::Evaluators::BaseEvaluator
      evaluator_class.new
    end
  end
end